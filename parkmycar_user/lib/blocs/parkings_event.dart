part of 'parkings_bloc.dart';

sealed class ParkingsEvent {}

class LoadParkings extends ParkingsEvent {
  final String personId;
  LoadParkings({required this.personId});
}

class ReloadParkings extends ParkingsEvent {
  final String personId;
  ReloadParkings({required this.personId});
}
