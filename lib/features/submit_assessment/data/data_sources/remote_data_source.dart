import 'package:dio/dio.dart';
import 'package:heart_disease/core/network/api_endpoints.dart';
import 'package:heart_disease/core/network/dio_helper.dart';



class AssessmentRemoteDataSource {
  Future<Response> submit(Map<String, dynamic> data) async { // ← رجّع Response
    try {
      final response = await DioHelper.post(
        url: ApiEndpoints.submitAssessment,
        data: data,
      );
      return response; // ← رجّع الـ response
    } catch (e) {
      throw Exception("Server Error");
    }
  }
}