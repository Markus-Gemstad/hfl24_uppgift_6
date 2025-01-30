part of 'parking_spaces_bloc.dart';

sealed class ParkingSpacesEvent {}

class LoadParkingSpaces extends ParkingSpacesEvent {}

class SearchParkingSpaces extends ParkingSpacesEvent {
  final String query;
  SearchParkingSpaces({required this.query});
}

class ReloadParkingSpaces extends ParkingSpacesEvent {}
