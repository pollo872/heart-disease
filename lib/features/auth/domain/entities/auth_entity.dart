import 'package:heart_disease/features/auth/domain/entities/user_entity.dart';

class AuthEntity {
  final String token;
  final UserEntity user;

  const AuthEntity({
    required this.token,
    required this.user,
  });
}
