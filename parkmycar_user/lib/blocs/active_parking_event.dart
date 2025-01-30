part of 'active_parking_bloc.dart';

sealed class ActiveParkingEvent {}

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
  final Duration extendDuration;
  ActiveParkingExtend(this.parking, this.extendDuration);
}

final class ActiveParkingEnd extends ActiveParkingEvent {
  final Parking parking;
  ActiveParkingEnd(this.parking);
}
