import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import '../firebase_options.dart';

const String extendParkingAction = 'extend_parking';

// Called when a user clicka a notification action
@pragma('vm:entry-point')
void notificationTapBackground(
    NotificationResponse notificationResponse) async {
  if (notificationResponse.actionId == extendParkingAction) {
    await extendParking(notificationResponse.payload!);
  }

  // debugPrint('notificationTapBackground(): \n'
  //     'id: ${notificationResponse.id}\n'
  //     'actionId: ${notificationResponse.actionId}\n'
  //     'input: ${notificationResponse.input}\n'
  //     'notificationResponseType: ${notificationResponse.notificationResponseType}\n'
  //     'payload: ${notificationResponse.payload}');

  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    print('notification action tapped with id: ${notificationResponse.id}');
  }
}

Future<void> extendParking(String parkingId) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  ParkingFirebaseRepository parkingRepository = ParkingFirebaseRepository();
  Parking? parking = await parkingRepository.getById(parkingId);
  if (parking != null) {
    DateTime newEndTime = parking.endTime.add(const Duration(minutes: 1));
    // If new time is overdue, extend with 1 minute from now
    if (newEndTime.isBefore(DateTime.now())) {
      newEndTime = DateTime.now().add(const Duration(minutes: 1));
    }
    parking.endTime = newEndTime;
    await parkingRepository.update(parking);

    debugPrint('ParkingId: $parkingId, newEndTime: $newEndTime');

    // Load the parking space for the notification text (street address)
    parking.parkingSpace =
        await ParkingSpaceFirebaseRepository().getById(parking.parkingSpaceId);

    NotificationsRepository notificationsRepository =
        await NotificationsRepository.initialize();

    // Create a new notification for the extended parking
    notificationsRepository.scheduleNotification(
        title: "Din parkeringstid går snart ut!",
        content:
            "Parkeringstiden på ${parking.parkingSpace!.streetAddress} går ut om 40 sekunder.",
        deliveryTime: newEndTime.subtract(const Duration(seconds: 40)),
        id: 0,
        payload: parking.id);
  }
}

Future<void> _configureLocalTimeZone() async {
  if (kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  if (Platform.isWindows) {
    return;
  }
  final String timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

Future<FlutterLocalNotificationsPlugin> initializeNotifications() async {
  var flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  var initializationSettingsAndroid = const AndroidInitializationSettings(
      '@mipmap/ic_launcher'); // Change this to an icon of your choice if you want to fix it.
  var initializationSettingsIOS = DarwinInitializationSettings(
    notificationCategories: [
      DarwinNotificationCategory(
        'parkmycar_notify',
        actions: <DarwinNotificationAction>[
          DarwinNotificationAction.plain(
              extendParkingAction, 'Förläng sluttid med 1 minut'),
        ],
        options: <DarwinNotificationCategoryOption>{
          DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
        },
      )
    ],
  );
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {
      // Called when the user taps on a notification
      debugPrint('onDidReceiveNotificationResponse');
    },
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );
  return flutterLocalNotificationsPlugin;
}

class NotificationsRepository {
  // singleton

  static Future<NotificationsRepository> initialize() async {
    if (_instance != null) {
      return _instance!;
    }
    await _configureLocalTimeZone();
    final plugin = await initializeNotifications();
    _instance =
        NotificationsRepository._(flutterLocalNotificationsPlugin: plugin);
    return _instance!;
  }

  static NotificationsRepository? _instance;

  NotificationsRepository._(
      {required FlutterLocalNotificationsPlugin
          flutterLocalNotificationsPlugin})
      : _flutterLocalNotificationsPlugin =
            flutterLocalNotificationsPlugin; // private constructor

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  Future<void> cancelScheduledNotificaion(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  Future<void> scheduleNotification(
      {required String title,
      required String content,
      required DateTime deliveryTime,
      required int id,
      String? payload}) async {
    await requestPermissions();

    String channelId = const Uuid()
        .v4(); // id should be unique per message, but contents of the same notification can be updated if you write to the same id
    const String channelName =
        "notifications_channel"; // this can be anything, different channels can be configured to have different colors, sound, vibration, we wont do that here
    String channelDescription =
        "Standard notifications"; // description is optional but shows up in user system settings
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        channelId, channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
        actions: [
          const AndroidNotificationAction(
              extendParkingAction, 'Förläng parkering med 1 minut'),
        ]);
    var iOSPlatformChannelSpecifics =
        const DarwinNotificationDetails(categoryIdentifier: 'parkmycar_notify');
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // TZDateTime required to take daylight savings into considerations.
    tz.TZDateTime tzDeliveryTime = tz.TZDateTime.from(deliveryTime, tz.local);

    debugPrint('scheduleNotification() payload: $payload, '
        'tzDeliveryTime: $tzDeliveryTime');

    return await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, title, content, tzDeliveryTime, platformChannelSpecifics,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }

  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    }
  }
}
