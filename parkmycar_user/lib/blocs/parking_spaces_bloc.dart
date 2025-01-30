import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
// import 'package:stream_transform/stream_transform.dart';

import '../globals.dart';

part 'parking_spaces_event.dart';
part 'parking_spaces_state.dart';

// const _duration = Duration(milliseconds: 300);

// EventTransformer<Event> debounce<Event>(Duration duration) {
//   return (events, mapper) => events.debounce(duration).switchMap(mapper);
// }

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
}
