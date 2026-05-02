// import 'package:dio/dio.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'api_endpoints.dart';

// class DioHelper {
//   static late Dio dio;

//   static init() {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: ApiEndpoints.baseUrl,
//         receiveDataWhenStatusError: true,
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       ),
//     );
//    dio.interceptors.add(InterceptorsWrapper(
//     onRequest: (options, handler) async {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
      
//       if (token != null) {
//         options.headers['Authorization'] = 'Bearer $token';
//       }
//       return handler.next(options);
//     },
//   ));
 
//   dio.interceptors.add(LogInterceptor(
//     requestBody: true,
//     responseBody: true,
//     logPrint: (obj) => debugPrint(obj.toString()),
//   ));
//   }
  

//   static Future<Response> post({
//     required String url,
//     required Map<String, dynamic> data,
//   }) async {
//     return await dio.post(
//       url,
//       data: data,
//     );
//   }

//   static Future<Response> get({
//     required String url,
//     Map<String, dynamic>? query,
//   }) async {
//     return await dio.get(
//       url,
//       queryParameters: query,
//     );
//   }

 
// }
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_endpoints.dart';

class DioHelper {
  static late Dio dio;

  static init() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        receiveDataWhenStatusError: true,
        // ✅ Timeouts مناسبة للـ AI responses (ممكن تاخد وقت)
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          // ✅ مطلوب للـ Web (CORS)
          if (kIsWeb) 'Accept': 'application/json',
        },
      ),
    );

    // ✅ Token interceptor — يشتغل على web و mobile
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (_) {
            // SharedPreferences ممكن يفشل على web في بعض الحالات
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) {
          debugPrint('❌ DioError: ${error.response?.statusCode} | ${error.message}');
          return handler.next(error);
        },
      ),
    );

    // ✅ Log interceptor — debug فقط
    if (kDebugMode) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  static Future<Response> post({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    return await dio.post(url, data: data);
  }

  static Future<Response> get({
    required String url,
    Map<String, dynamic>? query,
  }) async {
    return await dio.get(url, queryParameters: query);
  }

  static Future<Response> put({
    required String url,
    required Map<String, dynamic> data,
  }) async {
    return await dio.put(url, data: data);
  }

  static Future<Response> delete({
    required String url,
  }) async {
    return await dio.delete(url);
  }
}