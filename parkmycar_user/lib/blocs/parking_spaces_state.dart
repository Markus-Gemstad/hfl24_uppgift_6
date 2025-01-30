part of 'parking_spaces_bloc.dart';

sealed class ParkingSpacesState extends Equatable {}

class ParkingSpacesInitial extends ParkingSpacesState {
  @override
  List<Object?> get props => [];
}

class ParkingSpacesLoading extends ParkingSpacesState {
  @override
  List<Object?> get props => [];
}

class ParkingSpacesLoaded extends ParkingSpacesState {
  final List<ParkingSpace> parkingSpaces;

  ParkingSpacesLoaded({required this.parkingSpaces});

  @override
  List<Object?> get props => [parkingSpaces];
}

class ParkingSpacesError extends ParkingSpacesState {
  final String message;
  ParkingSpacesError({required this.message});

  @override
  List<Object?> get props => [message];
}
