import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';

class ErrorMessageHandler {
  static String getMessage(dynamic error) {
    // Connectivity issues (thrown before ever reaching Dio)
    if (error is SocketException) {
      return 'Please check your internet connection and try again';
    }

    if (error is TimeoutException) {
      return 'The request took too long, please try again';
    }

    // Main case: Dio
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'The request took too long, please try again';

        case DioExceptionType.connectionError:
          return 'Please check your internet connection and try again';

        case DioExceptionType.badResponse:
          return _handleStatusCode(
            error.response?.statusCode,
            error.response?.data,
          );

        case DioExceptionType.cancel:
          return 'Request was cancelled';

        default:
          return 'Something went wrong, please try again';
      }
    }

    // Any plain Exception coming from the repository (throw Exception('...'))
    final message = error.toString();

    if (message.startsWith('Exception:')) {
      final cleaned = message.replaceFirst('Exception:', '').trim();
      // If the message is short and readable (written by you in the repo), show it as-is
      if (cleaned.isNotEmpty && cleaned.length < 100) {
        return cleaned;
      }
    }

    return 'Something went wrong, please try again';
  }

  static String _handleStatusCode(int? statusCode, dynamic data) {
    // If the server returns a clear error message in the response body
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }

    switch (statusCode) {
      case 400:
        return 'Invalid data, please check your input';
      case 401:
        return 'Incorrect email or password';
      case 404:
        return 'Account not found';
      case 409:
        return 'This email is already in use';
      case 422:
        return 'Please make sure your data is valid';
      case 500:
      case 502:
      case 503:
        return 'Server error, please try again later';
      default:
        return 'Something went wrong, please try again';
    }
  }
}
