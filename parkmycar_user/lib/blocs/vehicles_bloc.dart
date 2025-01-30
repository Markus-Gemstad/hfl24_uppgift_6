import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/globals.dart';

part 'vehicles_event.dart';
part 'vehicles_state.dart';

class VehiclesBloc extends Bloc<VehiclesEvent, VehiclesState> {
  final VehicleFirebaseRepository repository;

  VehiclesBloc({required this.repository}) : super(VehiclesInitial()) {
    on<VehiclesEvent>((event, emit) async {
      switch (event) {
        case LoadVehicles(personId: final personId):
          await onLoadVehicles(personId, emit);
        case UpdateVehicle(vehicle: final vehicle, personId: final personId):
          await onUpdateVehicle(vehicle, personId, emit);
        case CreateVehicle(vehicle: final vehicle, personId: final personId):
          await onCreateVehicle(vehicle, personId, emit);
        case DeleteVehicle(vehicle: final vehicle, personId: final personId):
          await onDeleteVehicle(vehicle, personId, emit);
      }
    });
  }

  Future<void> onLoadVehicles(
      String personId, Emitter<VehiclesState> emit) async {
    try {
      emit(VehiclesLoading());
      var vehicles = await _loadVehicles(personId);
      emit(VehiclesLoaded(vehicles: vehicles, pending: null));
    } on Exception catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<List<Vehicle>> _loadVehicles(String personId) async {
    var vehicles = await repository.getAll('regNr');

    // TODO Ersätt med bättre relationer mellan Vehicle och Person
    vehicles =
        vehicles.where((element) => element.personId == personId).toList();

    return vehicles;
  }

  Future<void> onCreateVehicle(
      Vehicle vehicle, String personId, Emitter<VehiclesState> emit) async {
    // Visa optimistisk uppdatering direkt
    final currentItems = switch (state) {
      VehiclesLoaded(vehicles: final vehicles) => [...vehicles],
      _ => <Vehicle>[],
    };
    currentItems.add(vehicle);
    currentItems.sort((a, b) => a.regNr.compareTo(b.regNr));
    emit(VehiclesLoaded(vehicles: currentItems, pending: vehicle));
    await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));

    try {
      // Faktiskt API-anrop
      await repository.create(vehicle);

      // Ladda om för att säkerställa konsistens
      final vehicles = await _loadVehicles(personId);
      emit(VehiclesLoaded(vehicles: vehicles));
    } on Exception catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> onUpdateVehicle(
      Vehicle vehicle, String personId, Emitter<VehiclesState> emit) async {
    // Visa optimistisk uppdatering direkt
    final currentItems = switch (state) {
      VehiclesLoaded(vehicles: final vehicles) => [...vehicles],
      _ => <Vehicle>[],
    };
    var index = currentItems.indexWhere((e) => vehicle.id == e.id);
    currentItems.removeAt(index);
    currentItems.insert(index, vehicle);
    currentItems.sort((a, b) => a.regNr.compareTo(b.regNr));
    emit(VehiclesLoaded(vehicles: currentItems, pending: vehicle));
    await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));

    try {
      // Faktiskt API-anrop
      await repository.update(vehicle);

      // Ladda om för att säkerställa konsistens
      var vehicles = await _loadVehicles(personId);
      emit(VehiclesLoaded(vehicles: vehicles));
    } on Exception catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }

  Future<void> onDeleteVehicle(
      Vehicle vehicle, String personId, Emitter<VehiclesState> emit) async {
    // Visa optimistisk uppdatering direkt
    final currentItems = switch (state) {
      VehiclesLoaded(:final vehicles) => [...vehicles],
      _ => <Vehicle>[],
    };
    emit(VehiclesLoaded(vehicles: currentItems, pending: vehicle));
    await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));

    try {
      // Faktiskt API-anrop
      await repository.delete(vehicle.id);

      // Ladda om för att säkerställa konsistens
      var vehicles = await _loadVehicles(personId);
      emit(VehiclesLoaded(vehicles: vehicles));
    } on Exception catch (e) {
      emit(VehiclesError(message: e.toString()));
    }
  }
}
