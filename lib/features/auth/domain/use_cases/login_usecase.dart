import 'package:heart_disease/features/auth/domain/auth_repo/auth_repository.dart';
import '../entities/auth_entity.dart';


class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthEntity> call(String email, String password) {
    return repository.login(email, password);
  }
}
