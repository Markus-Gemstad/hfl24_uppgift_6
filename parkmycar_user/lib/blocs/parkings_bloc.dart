import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/globals.dart';

part 'parkings_event.dart';
part 'parkings_state.dart';

class ParkingsBloc extends Bloc<ParkingsEvent, ParkingsState> {
  final ParkingFirebaseRepository repository;
  final ParkingSpaceFirebaseRepository repositorySpace;

  ParkingsBloc({required this.repository, required this.repositorySpace})
      : super(ParkingsInitial()) {
    on<ParkingsEvent>((event, emit) async {
      switch (event) {
        case LoadParkings(personId: final personId):
          await onLoadParkings(personId, emit);
        case ReloadParkings(personId: final personId):
          await onReloadParkings(personId, emit);
      }
    });
  }

  Future<void> onLoadParkings(
      String personId, Emitter<ParkingsState> emit) async {
    try {
      emit(ParkingsLoading());
      var parkings = await _loadParkings(personId);
      emit(ParkingsLoaded(parkings: parkings));
    } on Exception catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  Future<void> onReloadParkings(
      String personId, Emitter<ParkingsState> emit) async {
    try {
      var parkings = await _loadParkings(personId);
      await Future.delayed(Duration(milliseconds: delayLoadInMilliseconds));
      emit(ParkingsLoaded(parkings: parkings));
    } on Exception catch (e) {
      emit(ParkingsError(message: e.toString()));
    }
  }

  Future<List<Parking>> _loadParkings(String personId) async {
    var parkings = await repository.getAll('startTime', true);

    // TODO Ersätt med bättre relationer mellan Parking och Person
    parkings = parkings
        .where((element) => !element.isOngoing && element.personId == personId)
        .toList();

    List<Parking> removeItems = List.empty(growable: true);

    for (var item in parkings) {
      // TODO Ersätt med bättre relationer mellan Parking och ParkingSpace
      try {
        item.parkingSpace = await repositorySpace.getById(item.parkingSpaceId);
      } catch (e) {
        removeItems.add(item);
      }
    }

    // Remove any items where a ParkingSpace was not found.
    // Ugly handling of error with relations...
    for (var item in removeItems) {
      parkings.remove(item);
    }

    return parkings;
  }
}
