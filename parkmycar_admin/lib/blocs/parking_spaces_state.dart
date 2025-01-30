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
  final ParkingSpace? pending;

  ParkingSpacesLoaded({required this.parkingSpaces, this.pending});

  @override
  List<Object?> get props => [parkingSpaces, pending];
}

class ParkingSpacesError extends ParkingSpacesState {
  final String message;
  ParkingSpacesError({required this.message});

  @override
  List<Object?> get props => [message];
}
