import 'package:heart_disease/features/auth/domain/auth_repo/auth_repository.dart';
import 'package:heart_disease/features/auth/domain/entities/auth_entity.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthEntity> call(
     String email,
     String firstName,
     String lastName,
     String password,
  ) {
    return repository.register(
      email,
      firstName,
      lastName,
      password,
    );
  }
}
