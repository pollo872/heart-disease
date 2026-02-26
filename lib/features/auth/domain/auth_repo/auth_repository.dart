import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login(String email, String password);
  Future<AuthEntity> register(String email,String firstName,String lastName, String password);
  Future<bool> isLoggedIn();
  Future<void> logout();
}
