import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

import '../globals.dart';

part 'parking_spaces_event.dart';
part 'parking_spaces_state.dart';

class ParkingSpacesBloc extends Bloc<ParkingSpacesEvent, ParkingSpacesState> {
  final ParkingSpaceFirebaseRepository repository;
  String? currentQuery;

  ParkingSpacesBloc({required this.repository})
      : super(ParkingSpacesInitial()) {
    on<ParkingSpacesEvent>((event, emit) async {
      switch (event) {
        case LoadParkingSpaces():
          await onLoadParkingSpaces(emit);
        case SearchParkingSpaces(query: final query):
          currentQuery = query;
          await onSearchParkingSpaces(emit, query);
        case ReloadParkingSpaces():
          await onReloadParkingSpaces(emit);
        case UpdateParkingSpace(parkingSpace: final parkingSpace):
          await onUpdateParkingSpace(parkingSpace, emit);
        case CreateParkingSpace(parkingSpace: final parkingSpace):
          await onCreateParkingSpace(parkingSpace, emit);
        case DeleteParkingSpace(parkingSpace: final parkingSpace):
          await onDeleteParkingSpace(parkingSpace, emit);
      }
    });
  }

  Future<void> onLoadParkingSpaces(Emitter<ParkingSpacesState> emit) async {
    try {
      emit(ParkingSpacesLoading());
      var parkingSpaces = await _loadParkingSpaces();
      emit(ParkingSpacesLoaded(parkingSpaces: parkingSpaces));
    } on Exception catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  Future<void> onReloadParkingSpaces(Emitter<ParkingSpacesState> emit) async {
    try {
      var parkingSpaces = await _loadParkingSpaces(currentQuery);
      await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));
      emit(ParkingSpacesLoaded(parkingSpaces: parkingSpaces));
    } on Exception catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  Future<void> onSearchParkingSpaces(
      Emitter<ParkingSpacesState> emit, String query) async {
    try {
      emit(ParkingSpacesLoading());
      var parkingSpaces = await _loadParkingSpaces(query);
      emit(ParkingSpacesLoaded(parkingSpaces: parkingSpaces));
    } on Exception catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  Future<List<ParkingSpace>> _loadParkingSpaces([String? query]) async {
    var parkingSpaces = await repository.getAll('streetAddress');

    if (query != null && query.isNotEmpty) {
      parkingSpaces = parkingSpaces
          .where((e) =>
              e.streetAddress.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }

    return parkingSpaces;
  }

  Future<void> onCreateParkingSpace(
      ParkingSpace parkingSpace, Emitter<ParkingSpacesState> emit) async {
    // Visa optimistisk uppdatering direkt
    final currentItems = switch (state) {
      ParkingSpacesLoaded(parkingSpaces: final parkingSpaces) => [
          ...parkingSpaces
        ],
      _ => <ParkingSpace>[],
    };
    currentItems.add(parkingSpace);
    currentItems.sort((a, b) =>
        a.streetAddress.toLowerCase().compareTo(b.streetAddress.toLowerCase()));
    emit(ParkingSpacesLoaded(
        parkingSpaces: currentItems, pending: parkingSpace));
    await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));

    try {
      // Faktiskt API-anrop
      await repository.create(parkingSpace);

      // Ladda om för att säkerställa konsistens
      var parkingSpaces = await _loadParkingSpaces(currentQuery);
      emit(ParkingSpacesLoaded(parkingSpaces: parkingSpaces));
    } on Exception catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  Future<void> onUpdateParkingSpace(
      ParkingSpace parkingSpace, Emitter<ParkingSpacesState> emit) async {
    // Visa optimistisk uppdatering direkt
    final currentItems = switch (state) {
      ParkingSpacesLoaded(parkingSpaces: final parkingSpaces) => [
          ...parkingSpaces
        ],
      _ => <ParkingSpace>[],
    };
    var index = currentItems.indexWhere((e) => parkingSpace.id == e.id);
    currentItems.removeAt(index);
    currentItems.insert(index, parkingSpace);
    currentItems.sort((a, b) =>
        a.streetAddress.toLowerCase().compareTo(b.streetAddress.toLowerCase()));
    emit(ParkingSpacesLoaded(
        parkingSpaces: currentItems, pending: parkingSpace));
    await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));

    try {
      // Faktiskt API-anrop
      await repository.update(parkingSpace);

      // Ladda om för att säkerställa konsistens
      var parkingSpaces = await _loadParkingSpaces(currentQuery);
      emit(ParkingSpacesLoaded(parkingSpaces: parkingSpaces));
    } on Exception catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }

  Future<void> onDeleteParkingSpace(
      ParkingSpace parkingSpace, Emitter<ParkingSpacesState> emit) async {
    // Visa optimistisk uppdatering direkt
    final currentItems = switch (state) {
      ParkingSpacesLoaded(:final parkingSpaces) => [...parkingSpaces],
      _ => <ParkingSpace>[],
    };
    emit(ParkingSpacesLoaded(
        parkingSpaces: currentItems, pending: parkingSpace));
    await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));

    try {
      // Faktiskt API-anrop
      await repository.delete(parkingSpace.id);

      // Ladda om för att säkerställa konsistens
      var parkingSpaces = await _loadParkingSpaces(currentQuery);
      emit(ParkingSpacesLoaded(parkingSpaces: parkingSpaces));
    } on Exception catch (e) {
      emit(ParkingSpacesError(message: e.toString()));
    }
  }
}
