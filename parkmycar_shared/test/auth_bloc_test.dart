import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:parkmycar_shared/parkmycar_shared.dart';

class MockPersonRepository extends Mock implements PersonFirebaseRepository {}

class FakePerson extends Fake implements Parking {}

// Mock storage for hydrated_bloc
class MockStorage extends Mock implements Storage {}

late Storage hydratedStorage;

void initHydratedStorage() {
  TestWidgetsFlutterBinding.ensureInitialized();
  hydratedStorage = MockStorage();
  when(
    () => hydratedStorage.write(any(), any<dynamic>()),
  ).thenAnswer((_) async {});
  HydratedBloc.storage = hydratedStorage;
}
// End mock storage for hydrated_bloc

void main() {
  initHydratedStorage();

  group('AuthBloc', () {
    late PersonFirebaseRepository mockRepo;

    setUp(() {
      mockRepo = MockPersonRepository();
    });

    setUpAll(() {
      registerFallbackValue(FakePerson());
    });

    group('login/logout test', () {
      Person person = Person('Test Testsson', 'test@test.com', '1');

      blocTest<AuthBloc, AuthState>(
        'login success',
        setUp: () {
          when(() => mockRepo.getAll()).thenAnswer((_) async => [person]);
        },
        build: () => AuthBloc(
            authRepository: AuthRepository(), personRepository: mockRepo),
        //seed: () => AuthLoaded(parkings: []),
        act: (bloc) => bloc.add(AuthLoginRequested(person.email, 'password')),
        expect: () => [
          const AuthState.authenticating(),
          AuthState.authenticated(person),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll()).called(1);
        },
        wait: const Duration(seconds: 1),
      );

      blocTest<AuthBloc, AuthState>(
        'error',
        setUp: () {
          when(() => mockRepo.getAll())
              .thenThrow(Exception('Failed loading users'));
        },
        build: () => AuthBloc(
            authRepository: AuthRepository(), personRepository: mockRepo),
        //seed: () => AuthLoaded(parkings: []),
        act: (bloc) => bloc.add(AuthLoginRequested(person.email, 'password')),
        expect: () => [
          const AuthState.authenticating(),
          const AuthState.unauthenticated(),
        ],
        verify: (bloc) {
          verify(() => mockRepo.getAll()).called(1);
        },
        wait: const Duration(seconds: 1),
      );

      blocTest<AuthBloc, AuthState>(
        'logout success',
        build: () => AuthBloc(
            authRepository: AuthRepository(), personRepository: mockRepo),
        act: (bloc) => bloc.add(AuthLogoutRequested()),
        expect: () => [
          const AuthState.initial(),
        ],
      );
    });
  });
}
