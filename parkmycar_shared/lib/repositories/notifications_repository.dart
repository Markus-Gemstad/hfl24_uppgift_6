import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:uuid/uuid.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

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
      '@mipmap/ic_launcher'); // TODO: Change this to an icon of your choice if you want to fix it.
  var initializationSettingsIOS = const DarwinInitializationSettings();
  var initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
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
      required int id}) async {
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
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = const DarwinNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);

    // from docs, not sure about specifics

    return await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        content,
        tz.TZDateTime.from(
            deliveryTime,
            tz
                .local), // TZDateTime required to take daylight savings into considerations.
        platformChannelSpecifics,
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
