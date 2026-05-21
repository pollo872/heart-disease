import 'package:dio/dio.dart';
import 'package:heart_disease/core/network/dio_helper.dart';
import 'package:heart_disease/core/network/api_endpoints.dart';

class UpdateProfileRemoteDataSource {
  Future<Response> updateProfile(Map<String, dynamic> data) async {
    try {
      return await DioHelper.put(
        url: ApiEndpoints.updateProfile,
        data: data,
      );
    } catch (e) {
      throw Exception("Server Error");
    }
  }
}