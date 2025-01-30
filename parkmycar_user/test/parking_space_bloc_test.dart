import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/blocs/parking_spaces_bloc.dart';
import 'package:parkmycar_user/globals.dart';

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
  });
}
