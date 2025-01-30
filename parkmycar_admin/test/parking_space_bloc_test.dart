import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_admin/blocs/parking_spaces_bloc.dart';
import 'package:parkmycar_admin/globals.dart';

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceFirebaseRepository {}

class FakeParkingSpace extends Fake implements ParkingSpace {}

void main() {
  group('ParkingSpacesBloc', () {
    late ParkingSpaceFirebaseRepository mockRepo;

    setUp(() {
      mockRepo = MockParkingSpaceRepository();
    });

    setUpAll(() {
      registerFallbackValue(
        FakeParkingSpace(),
      );
    });

    group('load parkingspaces test', () {
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'load',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [parkingSpace]);
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: []),
        act: (bloc) => bloc.add(LoadParkingSpaces()),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'error',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenThrow(Exception('Failed to load parkingSpaces'));
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: []),
        act: (bloc) => bloc.add(LoadParkingSpaces()),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesError(
              message: 'Exception: Failed to load parkingSpaces'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );
    });

    group('reload parkingSpaces test', () {
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'reload',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [parkingSpace]);
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: []),
        act: (bloc) => bloc.add(LoadParkingSpaces()),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'error',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenThrow(Exception('Failed to load parkingSpaces'));
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: []),
        act: (bloc) => bloc.add(LoadParkingSpaces()),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesError(
              message: 'Exception: Failed to load parkingSpaces'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );
    });

    group('search parkingSpaces test', () {
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');
      String query = 'Gatan';

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'search',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [parkingSpace]);
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        act: (bloc) => bloc.add(SearchParkingSpaces(query: query)),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'error',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenThrow(Exception('Failed to search parkingSpaces'));
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        act: (bloc) => bloc.add(SearchParkingSpaces(query: query)),
        expect: () => [
          ParkingSpacesLoading(),
          ParkingSpacesError(
              message: 'Exception: Failed to search parkingSpaces'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );
    });

    group('create parkingSpace test', () {
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'create',
        setUp: () {
          when(() => mockRepo.create(any()))
              .thenAnswer((_) async => parkingSpace);
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [parkingSpace]);
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: []),
        act: (bloc) => bloc.add(CreateParkingSpace(parkingSpace: parkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [parkingSpace], pending: parkingSpace),
          ParkingSpacesLoaded(parkingSpaces: [parkingSpace], pending: null),
        ],
        verify: (bloc) {
          verify(() => mockRepo.create(parkingSpace)).called(1);
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'error',
        setUp: () {
          when(() => mockRepo.create(any()))
              .thenThrow(Exception('Failed to create parkingSpace'));
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: []),
        act: (bloc) => bloc.add(CreateParkingSpace(parkingSpace: parkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [parkingSpace], pending: parkingSpace),
          ParkingSpacesError(
              message: 'Exception: Failed to create parkingSpace'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.create(parkingSpace)).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );
    });

    group('update parkingSpace test', () {
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'update',
        setUp: () {
          when(() => mockRepo.update(any()))
              .thenAnswer((_) async => parkingSpace);
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [parkingSpace]);
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        act: (bloc) => bloc.add(UpdateParkingSpace(parkingSpace: parkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [parkingSpace], pending: parkingSpace),
          ParkingSpacesLoaded(parkingSpaces: [parkingSpace], pending: null),
        ],
        verify: (bloc) {
          verify(() => mockRepo.update(parkingSpace)).called(1);
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'error',
        setUp: () {
          when(() => mockRepo.update(any()))
              .thenThrow(Exception('Failed to update parkingSpace'));
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        act: (bloc) => bloc.add(UpdateParkingSpace(parkingSpace: parkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [parkingSpace], pending: parkingSpace),
          ParkingSpacesError(
              message: 'Exception: Failed to update parkingSpace'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.update(parkingSpace)).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );
    });

    group('delete parkingSpace test', () {
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'delete item test',
        setUp: () {
          when(() => mockRepo.delete(any())).thenAnswer((_) async => true);
          when(() => mockRepo.getAll(any(), any())).thenAnswer((_) async => []);
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        act: (bloc) => bloc.add(DeleteParkingSpace(parkingSpace: parkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [parkingSpace], pending: parkingSpace),
          ParkingSpacesLoaded(parkingSpaces: [], pending: null),
        ],
        verify: (bloc) {
          verify(() => mockRepo.delete(parkingSpace.id)).called(1);
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<ParkingSpacesBloc, ParkingSpacesState>(
        'error',
        setUp: () {
          when(() => mockRepo.delete(any()))
              .thenThrow(Exception('Failed to delete parkingSpace'));
        },
        build: () => ParkingSpacesBloc(repository: mockRepo),
        seed: () => ParkingSpacesLoaded(parkingSpaces: [parkingSpace]),
        act: (bloc) => bloc.add(DeleteParkingSpace(parkingSpace: parkingSpace)),
        expect: () => [
          ParkingSpacesLoaded(
              parkingSpaces: [parkingSpace], pending: parkingSpace),
          ParkingSpacesError(
              message: 'Exception: Failed to delete parkingSpace'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.delete(parkingSpace.id)).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );
    });
  });
}
