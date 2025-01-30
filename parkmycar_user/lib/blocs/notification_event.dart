part of 'notification_bloc.dart';

sealed class NotificationEvent {}

class ScheduleNotification extends NotificationEvent {
  final String id;
  final String title;
  final String content;
  final DateTime deliveryTime;

  ScheduleNotification(
      {required this.id,
      required this.title,
      required this.content,
      required this.deliveryTime});
}

class CancelNotification extends NotificationEvent {
  final String id;

  CancelNotification({
    required this.id,
  });
}
