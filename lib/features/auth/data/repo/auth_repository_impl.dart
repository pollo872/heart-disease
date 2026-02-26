import 'package:heart_disease/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:heart_disease/features/auth/data/data_sources/local_data_source.dart';
import 'package:heart_disease/features/auth/domain/auth_repo/auth_repository.dart';

import '../../domain/entities/auth_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final AuthLocalDataSource local;

  AuthRepositoryImpl(this.remote, this.local);

  @override
  Future<AuthEntity> login(String email, String password) async {
    final result = await remote.login(email: email, password: password);

    await local.saveToken(result.token);

    return result;
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await local.getToken();
    return token != null;
  }

  @override
  Future<void> logout() async {
    await local.clearToken();
  }

  @override
  Future<AuthEntity> register(
      String email, String firstName, String lastName, String password) {
    return remote.register(
        email: email,
        firstName: firstName,
        lastName: lastName,
        password: password);
  }
}
