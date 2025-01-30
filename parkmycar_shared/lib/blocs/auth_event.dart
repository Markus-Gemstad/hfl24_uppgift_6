part of 'auth_bloc.dart';

abstract class AuthEvent {}

// Add this event on app start, subscribe to auth changes
class AuthUserSubscriptionRequested extends AuthEvent {}

class AuthRegister extends AuthEvent {
  final String email;
  final String password;

  AuthRegister(this.email, this.password);
}

class AuthFinalizeRegistration extends AuthEvent {
  final String authId;
  final String email;
  final String name;

  AuthFinalizeRegistration(this.name, this.authId, this.email);
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
}

class AuthLogoutRequested extends AuthEvent {}
