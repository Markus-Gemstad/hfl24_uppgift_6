part of 'active_parking_bloc.dart';

enum ParkingStatus {
  nonActive,
  starting,
  active,
  extending,
  ending,
  error,
}

class ActiveParkingState extends Equatable {
  final ParkingStatus status;
  final Parking? parking;
  final String message;

  const ActiveParkingState._({
    this.status = ParkingStatus.nonActive,
    this.parking,
    this.message = '',
  });

  const ActiveParkingState.nonActive()
      : this._(status: ParkingStatus.nonActive, parking: null);

  const ActiveParkingState.starting(Parking parking)
      : this._(status: ParkingStatus.starting, parking: parking);

  const ActiveParkingState.active(Parking parking)
      : this._(status: ParkingStatus.active, parking: parking);

  const ActiveParkingState.extending(Parking parking)
      : this._(status: ParkingStatus.extending, parking: parking);

  const ActiveParkingState.ending() : this._(status: ParkingStatus.ending);

  const ActiveParkingState.error(String message)
      : this._(status: ParkingStatus.error, message: message, parking: null);

  @override
  List<Object?> get props => [status, parking, message];
}
