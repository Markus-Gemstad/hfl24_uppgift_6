part of 'notification_bloc.dart';

class NotificationState extends Equatable {
  final Map<String, int> scheduledIds;

  const NotificationState({required this.scheduledIds});

  bool isIdScheduled(String id) => scheduledIds.containsKey(id);

  @override
  List<Object?> get props => [scheduledIds];
}
