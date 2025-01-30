part of 'vehicles_bloc.dart';

sealed class VehiclesEvent {}

class LoadVehicles extends VehiclesEvent {
  final String personId;
  LoadVehicles({required this.personId});
}

class UpdateVehicle extends VehiclesEvent {
  final Vehicle vehicle;
  final String personId;
  UpdateVehicle({required this.vehicle, required this.personId});
}

class CreateVehicle extends VehiclesEvent {
  final Vehicle vehicle;
  final String personId;
  CreateVehicle({required this.vehicle, required this.personId});
}

class DeleteVehicle extends VehiclesEvent {
  final Vehicle vehicle;
  final String personId;
  DeleteVehicle({required this.vehicle, required this.personId});
}
