import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/blocs/vehicles_bloc.dart';
import 'package:parkmycar_user/globals.dart';

class MockVehicleRepository extends Mock implements VehicleFirebaseRepository {}

class FakeVehicle extends Fake implements Vehicle {}

void main() {
  group('VehiclesBloc', () {
    late VehicleFirebaseRepository mockRepo;

    setUp(() {
      mockRepo = MockVehicleRepository();
    });

    setUpAll(() {
      registerFallbackValue(
        FakeVehicle(),
      );
    });

    group('create vehicle test', () {
      Vehicle vehicle = Vehicle('ABC123', '1', VehicleType.car);

      blocTest<VehiclesBloc, VehiclesState>(
        'create',
        setUp: () {
          when(() => mockRepo.create(any())).thenAnswer((_) async => vehicle);
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [vehicle]);
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: []),
        act: (bloc) => bloc.add(CreateVehicle(vehicle: vehicle, personId: '1')),
        expect: () => [
          VehiclesLoaded(vehicles: [vehicle], pending: vehicle),
          VehiclesLoaded(vehicles: [vehicle], pending: null),
        ],
        verify: (bloc) {
          verify(() => mockRepo.create(vehicle)).called(1);
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<VehiclesBloc, VehiclesState>(
        'error',
        setUp: () {
          when(() => mockRepo.create(any()))
              .thenThrow(Exception('Failed to create vehicle'));
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: []),
        act: (bloc) => bloc.add(CreateVehicle(vehicle: vehicle, personId: '1')),
        expect: () => [
          VehiclesLoaded(vehicles: [vehicle], pending: vehicle),
          VehiclesError(message: 'Exception: Failed to create vehicle'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.create(vehicle)).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );
    });

    group('update vehicle test', () {
      Vehicle vehicle = Vehicle('ABC123', '1', VehicleType.car, '1');

      blocTest<VehiclesBloc, VehiclesState>(
        'update',
        setUp: () {
          when(() => mockRepo.update(any())).thenAnswer((_) async => vehicle);
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [vehicle]);
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: [vehicle]),
        act: (bloc) => bloc.add(UpdateVehicle(vehicle: vehicle, personId: '1')),
        expect: () => [
          VehiclesLoaded(vehicles: [vehicle], pending: vehicle),
          VehiclesLoaded(vehicles: [vehicle], pending: null),
        ],
        verify: (bloc) {
          verify(() => mockRepo.update(vehicle)).called(1);
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<VehiclesBloc, VehiclesState>(
        'error',
        setUp: () {
          when(() => mockRepo.update(any()))
              .thenThrow(Exception('Failed to update vehicle'));
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: [vehicle]),
        act: (bloc) => bloc.add(UpdateVehicle(vehicle: vehicle, personId: '1')),
        expect: () => [
          VehiclesLoaded(vehicles: [vehicle], pending: vehicle),
          VehiclesError(message: 'Exception: Failed to update vehicle'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.update(vehicle)).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );
    });

    group('delete vehicle test', () {
      Vehicle vehicle = Vehicle('ABC123', '1', VehicleType.car, '1');

      blocTest<VehiclesBloc, VehiclesState>(
        'delete item test',
        setUp: () {
          when(() => mockRepo.delete(any())).thenAnswer((_) async => true);
          when(() => mockRepo.getAll(any(), any())).thenAnswer((_) async => []);
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: [vehicle]),
        act: (bloc) => bloc.add(DeleteVehicle(vehicle: vehicle, personId: '1')),
        expect: () => [
          VehiclesLoaded(vehicles: [vehicle], pending: vehicle),
          VehiclesLoaded(vehicles: [], pending: null),
        ],
        verify: (bloc) {
          verify(() => mockRepo.delete(vehicle.id)).called(1);
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<VehiclesBloc, VehiclesState>(
        'error',
        setUp: () {
          when(() => mockRepo.delete(any()))
              .thenThrow(Exception('Failed to delete vehicle'));
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: [vehicle]),
        act: (bloc) => bloc.add(DeleteVehicle(vehicle: vehicle, personId: '1')),
        expect: () => [
          VehiclesLoaded(vehicles: [vehicle], pending: vehicle),
          VehiclesError(message: 'Exception: Failed to delete vehicle'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.delete(vehicle.id)).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );
    });

    group('load vehicles test', () {
      Vehicle vehicle = Vehicle('ABC123', '1', VehicleType.car, '1');

      blocTest<VehiclesBloc, VehiclesState>(
        'load items test',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [vehicle]);
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: []),
        act: (bloc) => bloc.add(LoadVehicles(personId: '1')),
        expect: () => [
          VehiclesLoading(),
          VehiclesLoaded(vehicles: [vehicle]),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );

      blocTest<VehiclesBloc, VehiclesState>(
        'error',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenThrow(Exception('Failed to load vehicles'));
        },
        build: () => VehiclesBloc(repository: mockRepo),
        seed: () => VehiclesLoaded(vehicles: []),
        act: (bloc) => bloc.add(LoadVehicles(personId: '1')),
        expect: () => [
          VehiclesLoading(),
          VehiclesError(message: 'Exception: Failed to load vehicles'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );
    });
  });
}
