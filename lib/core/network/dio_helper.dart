import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'api_endpoints.dart';

class DioHelper {
  static late Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        receiveDataWhenStatusError: true,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    dio.interceptors.add(LogInterceptor(
  requestBody: true, 
  responseBody: true,
  logPrint: (obj) => debugPrint(obj.toString()),
));
  }

  static Future<Response> post({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    return await dio.post(url, data: data);
  }
}
