import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';
import 'package:parkmycar_user/blocs/parkings_bloc.dart';
import 'package:parkmycar_user/globals.dart';

class MockParkingRepository extends Mock implements ParkingFirebaseRepository {}

class MockParkingSpaceRepository extends Mock
    implements ParkingSpaceFirebaseRepository {}

class FakeParking extends Fake implements Parking {}

class FakeParkingSpace extends Fake implements ParkingSpace {}

void main() {
  group('ParkingsBloc', () {
    late ParkingFirebaseRepository mockRepo;
    late ParkingSpaceFirebaseRepository mockSpaceRepo;

    setUp(() {
      mockRepo = MockParkingRepository();
      mockSpaceRepo = MockParkingSpaceRepository();
    });

    setUpAll(() {
      registerFallbackValue(FakeParking());
      registerFallbackValue(FakeParkingSpace());
    });

    group('load parkings test', () {
      Parking parking = Parking(
          '1',
          '1',
          '1',
          DateTime.parse('20250101 12:00:00'),
          DateTime.parse('20250101 13:00:00'),
          100,
          '1');
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');

      blocTest<ParkingsBloc, ParkingsState>(
        'load',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [parking]);
          when(() => mockSpaceRepo.getById(any()))
              .thenAnswer((_) async => parkingSpace);
        },
        build: () =>
            ParkingsBloc(repository: mockRepo, repositorySpace: mockSpaceRepo),
        seed: () => ParkingsLoaded(parkings: []),
        act: (bloc) => bloc.add(LoadParkings(personId: '1')),
        expect: () => [
          ParkingsLoading(),
          ParkingsLoaded(parkings: [parking]),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
          verify(() => mockSpaceRepo.getById(any())).called(1);
        },
      );

      blocTest<ParkingsBloc, ParkingsState>(
        'error',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenThrow(Exception('Failed to load parkings'));
        },
        build: () =>
            ParkingsBloc(repository: mockRepo, repositorySpace: mockSpaceRepo),
        seed: () => ParkingsLoaded(parkings: []),
        act: (bloc) => bloc.add(LoadParkings(personId: '1')),
        expect: () => [
          ParkingsLoading(),
          ParkingsError(message: 'Exception: Failed to load parkings'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );
    });

    group('reload parkings test', () {
      Parking parking = Parking(
          '1',
          '1',
          '1',
          DateTime.parse('20250101 12:00:00'),
          DateTime.parse('20250101 13:00:00'),
          100,
          '1');
      ParkingSpace parkingSpace =
          ParkingSpace('Gatan 10', '12345', 'Ort', 100, '1');

      blocTest<ParkingsBloc, ParkingsState>(
        'reload',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenAnswer((_) async => [parking]);
          when(() => mockSpaceRepo.getById(any()))
              .thenAnswer((_) async => parkingSpace);
        },
        build: () =>
            ParkingsBloc(repository: mockRepo, repositorySpace: mockSpaceRepo),
        seed: () => ParkingsLoaded(parkings: []),
        act: (bloc) => bloc.add(LoadParkings(personId: '1')),
        expect: () => [
          ParkingsLoading(),
          ParkingsLoaded(parkings: [parking]),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
          verify(() => mockSpaceRepo.getById(any())).called(1);
        },
        wait: Duration(milliseconds: delayLoadInMilliseconds),
      );

      blocTest<ParkingsBloc, ParkingsState>(
        'error',
        setUp: () {
          when(() => mockRepo.getAll(any(), any()))
              .thenThrow(Exception('Failed to load parkings'));
        },
        build: () =>
            ParkingsBloc(repository: mockRepo, repositorySpace: mockSpaceRepo),
        seed: () => ParkingsLoaded(parkings: []),
        act: (bloc) => bloc.add(LoadParkings(personId: '1')),
        expect: () => [
          ParkingsLoading(),
          ParkingsError(message: 'Exception: Failed to load parkings'),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll(any(), any())).called(1);
        },
      );
    });
  });
}
