import 'package:dio/dio.dart';
import 'package:heart_disease/core/network/api_endpoints.dart';

import '../models/auth_response_model.dart';

class AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSource(this.dio);
 

  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200 && response.data != null) {
      return AuthResponseModel.fromJson(response.data);
    } else {
      throw Exception('Login failed');
    }
  }

  Future<AuthResponseModel> register({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final response = await dio.post(
      ApiEndpoints.signUp,
      data: {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'password': password,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }
}
