import '../../domain/entities/user_entity.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final UserEntity user;

  AuthSuccess({
    required this.token,
    required this.user,
  });
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
