import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../repositories/notifications_repository.dart';

part 'notification_state.dart';
part 'notification_event.dart';

class NotificationBloc
    extends HydratedBloc<NotificationEvent, NotificationState> {
  final NotificationsRepository repository;

  NotificationBloc(this.repository)
      : super(const NotificationState(scheduledIds: {})) {
    on<NotificationEvent>((event, emit) async {
      switch (event) {
        case ScheduleNotification(
            :final id,
            :final title,
            :final content,
            :final deliveryTime,
            :final payload
          ):
          await _onScheduleNotification(
              deliveryTime, title, content, id, payload, emit);

        case CancelNotification(:final id):
          await _onCancelNotification(id, emit);
      }
    });
  }

  Future<void> _onCancelNotification(
      String id, Emitter<NotificationState> emit) async {
    final notificationId = state.scheduledIds[id];
    if (notificationId != null) {
      await repository.cancelScheduledNotification(notificationId);
      final newState = Map<String, int>.from(state.scheduledIds);
      newState.remove(id);
      emit(NotificationState(scheduledIds: newState));
    }
  }

  Future<void> _onScheduleNotification(
      DateTime deliveryTime,
      String title,
      String content,
      String id,
      String? payload,
      Emitter<NotificationState> emit) async {
    var random = Random();

    int notificationId = random.nextInt((pow(2, 31).toInt() - 1));

    await repository.scheduleNotification(
        id: notificationId,
        title: title,
        content: content,
        deliveryTime: deliveryTime,
        payload: payload);

    final newState = Map<String, int>.from(state.scheduledIds);
    newState[id] = notificationId;
    emit(NotificationState(scheduledIds: newState));
  }

  @override
  NotificationState? fromJson(Map<String, dynamic> json) {
    if (json['scheduledIds'] == null) {
      return const NotificationState(scheduledIds: {});
    } else {
      return NotificationState(scheduledIds: json['scheduledIds']);
    }
  }

  @override
  Map<String, dynamic>? toJson(NotificationState state) {
    return {'scheduledIds': state.scheduledIds};
  }
}
