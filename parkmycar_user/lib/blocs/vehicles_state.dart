part of 'vehicles_bloc.dart';

sealed class VehiclesState extends Equatable {}

class VehiclesInitial extends VehiclesState {
  @override
  List<Object?> get props => [];
}

class VehiclesLoading extends VehiclesState {
  @override
  List<Object?> get props => [];
}

class VehiclesLoaded extends VehiclesState {
  final List<Vehicle> vehicles;
  final Vehicle? pending;

  VehiclesLoaded({required this.vehicles, this.pending});

  @override
  List<Object?> get props => [vehicles, pending];
}

class VehiclesError extends VehiclesState {
  final String message;
  VehiclesError({required this.message});

  @override
  List<Object?> get props => [message];
}
