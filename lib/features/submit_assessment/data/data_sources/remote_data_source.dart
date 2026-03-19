import 'package:heart_disease/core/network/api_endpoints.dart';
import 'package:heart_disease/core/network/dio_helper.dart';



class AssessmentRemoteDataSource {
  Future<void> submit(Map<String, dynamic> data) async {
    try {
      await DioHelper.post(
        url: ApiEndpoints.submitAssessment,
        data: data,
      );
    } catch (e) {
      throw Exception("Server Error");
    }
  }
}