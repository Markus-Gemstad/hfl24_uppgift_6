part of 'auth_bloc.dart';

enum AuthStateStatus {
  initial,
  authenticating,
  authenticatedNoPerson,
  authenticatedNoPersonPending,
  authenticated,
  unauthenticated
}

class AuthState extends Equatable {
  final AuthStateStatus status;
  final Person? person;
  final String? authId;
  final String? email;
  final String? errorMessage;

  const AuthState._({
    this.status = AuthStateStatus.initial,
    this.person,
    this.authId,
    this.email,
    this.errorMessage,
  });

  const AuthState.initial() : this._();

  const AuthState.authenticating()
      : this._(status: AuthStateStatus.authenticating, person: null);

  const AuthState.authenticatedNoPerson(String authId, String email)
      : this._(
            status: AuthStateStatus.authenticatedNoPerson,
            person: null,
            authId: authId,
            email: email);

  const AuthState.authenticatedNoPersonPending(String authId, String email)
      : this._(
            status: AuthStateStatus.authenticatedNoPersonPending,
            person: null,
            authId: authId,
            email: email);

  const AuthState.authenticated(Person person)
      : this._(status: AuthStateStatus.authenticated, person: person);

  const AuthState.unauthenticated()
      : this._(status: AuthStateStatus.unauthenticated, person: null);

  const AuthState.failure(String? errorMessage)
      : this._(
            status: AuthStateStatus.unauthenticated,
            errorMessage: errorMessage);

  @override
  List<Object?> get props => [status, person];
}
