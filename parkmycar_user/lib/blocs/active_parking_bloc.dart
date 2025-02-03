import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

part 'active_parking_state.dart';
part 'active_parking_event.dart';

class ActiveParkingBloc extends Bloc<ActiveParkingEvent, ActiveParkingState> {
  final ParkingFirebaseRepository parkingRepository;

  ActiveParkingBloc({required this.parkingRepository})
      : super(ActiveParkingState.nonActive()) {
    on<ActiveParkingSubscriptionRequested>((event, emit) async =>
        await _onActiveParkingSubscriptionRequested(event, emit));
    on<ActiveParkingInit>(
        (event, emit) async => await _initParking(event, emit));
    on<ActiveParkingExtend>(
        (event, emit) async => await _extendParking(event, emit));
    on<ActiveParkingStart>(
        (event, emit) async => await _startParking(event, emit));
    on<ActiveParkingEnd>((event, emit) async => await _endParking(event, emit));
  }

  Future<void> _onActiveParkingSubscriptionRequested(
      ActiveParkingSubscriptionRequested event,
      Emitter<ActiveParkingState> emit) async {
    await emit.onEach(parkingRepository.getOngoingParkingStream(event.personId),
        onData: (parking) async {
      if (parking != null) {
        emit(ActiveParkingState.active(parking));
      }
    });
  }

  Future<void> _initParking(
      ActiveParkingInit event, Emitter<ActiveParkingState> emit) async {
    // Find active parking
    final parking =
        await parkingRepository.getFirstOngoingParking(event.personId);
    if (parking != null) {
      emit(ActiveParkingState.active(parking));
    }
  }

  Future<void> _startParking(ActiveParkingStart event, emit) async {
    emit(ActiveParkingState.starting(event.parking));
    try {
      // TODO Ersätt med bättre relationer mellan Parking och ParkingSpace
      // Do a little work-around for ParkingSpace since the returning
      // Parking object from create does not contain a ParkingSpace but
      // the provided parking param should contain a ParkingSpace object
      // (see ParkingStartDialog start parking button onPressed method).
      ParkingSpace parkingSpace = event.parking.parkingSpace!;

      Parking? newParking = await parkingRepository.create(event.parking);
      debugPrint(
          'Parking created: ${event.parking}, parkingSpace: ${event.parking.parkingSpace}');
      newParking!.parkingSpace = parkingSpace;
      emit(ActiveParkingState.active(newParking));
    } catch (e) {
      debugPrint('Error when creating Parking: ${event.parking}, Error: $e');
      emit(ActiveParkingState.error(e.toString()));
    }
  }

  Future<void> _extendParking(
      ActiveParkingExtend event, Emitter<ActiveParkingState> emit) async {
    emit(ActiveParkingState.extending(event.parking));
    try {
      event.parking.endTime = event.parking.endTime = event.newEndTime;

      await parkingRepository.update(event.parking);
      debugPrint(
          'Parking extended: ${event.parking}, parkingSpace: ${event.parking.parkingSpace}');
      emit(ActiveParkingState.active(event.parking));
    } catch (e) {
      debugPrint('Error when extending Parking: ${event.parking}, Error: $e');
      emit(ActiveParkingState.error(e.toString()));
    }
  }

  Future<void> _endParking(ActiveParkingEnd event, emit) async {
    emit(ActiveParkingState.ending());
    try {
      if (event.newEndTime != null) {
        event.parking.endTime = event.newEndTime!;
        await parkingRepository.update(event.parking);
      }
      debugPrint(
          'Parking stopped: ${event.parking}, parkingSpace: ${event.parking.parkingSpace}');
      emit(ActiveParkingState.nonActive());
    } catch (e) {
      debugPrint('Error when ending Parking: ${event.parking}, Error: $e');
      emit(ActiveParkingState.error(e.toString()));
    }
  }

  // @override
  // ActiveParkingState fromJson(Map<String, dynamic> json) {
  //   return switch (ParkingStatus.values[json['status']]) {
  //     ParkingStatus.starting => ActiveParkingState.starting(
  //         ParkingSerializer().fromJson(json['parking'])),
  //     ParkingStatus.active => ActiveParkingState.active(
  //         ParkingSerializer().fromJson(json['parking'])),
  //     _ => ActiveParkingState.nonActive(),
  //   };
  // }

  // @override
  // Map<String, dynamic>? toJson(ActiveParkingState state) {
  //   return {
  //     'status': state.status.toString(),
  //     'parking': state.parking == null
  //         ? null
  //         : ParkingSerializer().toJson(state.parking!),
  //     'message': state.message,
  //   };
  // }
}
