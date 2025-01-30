import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:parkmycar_shared/repositories/auth_repository.dart';
import '../models/person.dart';
import '../repositories/person_firebase_repository.dart';

part 'auth_state.dart';
part 'auth_event.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final PersonFirebaseRepository personRepository;

  AuthBloc({required this.authRepository, required this.personRepository})
      : super(const AuthState.initial()) {
    on<AuthUserSubscriptionRequested>(
        (event, emit) async => await _onUserSubscriptionRequested(event, emit));
    // on<AuthRegister>((event, emit) async => await _onRegister(event, emit));
    on<AuthFinalizeRegistration>(
        (event, emit) async => await _onFinalizeRegistration(event, emit));
    on<AuthLoginRequested>((event, emit) async => await _onLogin(event, emit));
    on<AuthLogoutRequested>(
        (event, emit) async => await _onLogout(event, emit));
  }

  Future<void> _onUserSubscriptionRequested(event, emit) async {
    await emit.onEach(authRepository.userStream, onData: (authUser) async {
      if (authUser == null) {
        emit(const AuthState.unauthenticated());
      } else {
        Person? person = await personRepository.getByAuthId(authUser.uid);
        if (person == null) {
          emit(AuthState.authenticatedNoPerson(authUser.uid, authUser.email!));
        } else {
          emit(AuthState.authenticated(person));
        }
      }
    });
  }

  // Future<void> _onRegister(AuthRegister event, emit) async {
  //   emit(const AuthState.authenticating());
  //   try {
  //     await authRepository.register(
  //         email: event.email, password: event.password);
  //   } on SignUpWithEmailAndPasswordFailure catch (e) {
  //     emit(AuthState.failure(e.message));
  //   } catch (_) {
  //     emit(const AuthState.failure('Unknown error'));
  //   }
  // }

  Future<void> _onFinalizeRegistration(
      AuthFinalizeRegistration event, emit) async {
    emit(AuthState.authenticatedNoPersonPending(event.authId, event.email));
    final person = await personRepository
        .create(Person(event.name, event.email, event.authId));

    // This operation does not trigger a change on the auth stream.
    emit(AuthState.authenticated(person!));
  }

  Future<void> _onLogin(AuthLoginRequested event, emit) async {
    emit(const AuthState.authenticating());
    try {
      // Login to firebase authorization
      await authRepository.login(email: event.email, password: event.password);
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(AuthState.failure(e.message));
    } catch (_) {
      emit(const AuthState.failure('Unknown error'));
    }

    // No reason to emit state here because this triggers a change on the
    // authStateChanges stream, the stream handler will emit the appropriate state
    // emit(const AuthState.unauthenticated());
  }

  Future<void> _onLogout(AuthLogoutRequested event, emit) async {
    await authRepository.logout();
    // No reason to emit state here because this triggers a change on the
    // authStateChanges stream, the stream handler will emit the appropriate state
    // emit(const AuthState.initial());
  }
}
