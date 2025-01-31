part of 'active_parking_bloc.dart';

sealed class ActiveParkingEvent {}

// Add this event on app start, subscribe to active parking changes
final class ActiveParkingSubscriptionRequested extends ActiveParkingEvent {
  final String personId;
  ActiveParkingSubscriptionRequested(this.personId);
}

final class ActiveParkingInit extends ActiveParkingEvent {
  final String personId;
  ActiveParkingInit(this.personId);
}

final class ActiveParkingStart extends ActiveParkingEvent {
  final Parking parking;
  ActiveParkingStart(this.parking);
}

final class ActiveParkingExtend extends ActiveParkingEvent {
  final Parking parking;
  final DateTime newEndTime;
  ActiveParkingExtend(this.parking, this.newEndTime);
}

final class ActiveParkingEnd extends ActiveParkingEvent {
  final Parking parking;
  ActiveParkingEnd(this.parking);
}
