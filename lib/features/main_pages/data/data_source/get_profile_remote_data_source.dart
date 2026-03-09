import 'package:dio/dio.dart';
import '../../../../core/network/dio_helper.dart';
import '../../../../core/network/api_endpoints.dart';

class MainRemoteDataSource {

  Future<Response> getProfile() async {
    return await DioHelper.get(
      url: ApiEndpoints.profile,
    );
  }

}