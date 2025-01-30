part of 'parking_spaces_bloc.dart';

sealed class ParkingSpacesEvent {}

class LoadParkingSpaces extends ParkingSpacesEvent {}

class SearchParkingSpaces extends ParkingSpacesEvent {
  final String query;
  SearchParkingSpaces({required this.query});
}

class ReloadParkingSpaces extends ParkingSpacesEvent {}

class UpdateParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;
  UpdateParkingSpace({required this.parkingSpace});
}

class CreateParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;
  CreateParkingSpace({required this.parkingSpace});
}

class DeleteParkingSpace extends ParkingSpacesEvent {
  final ParkingSpace parkingSpace;
  DeleteParkingSpace({required this.parkingSpace});
}
