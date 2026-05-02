import 'package:dio/dio.dart';
import 'package:heart_disease/core/network/api_endpoints.dart';
import 'package:heart_disease/core/network/dio_helper.dart';
import 'package:heart_disease/features/chat/chat_message_model.dart';


class ChatRepository {
  /// ترسل رسالة وترجع رد الـ AI
  Future<String> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
  }) async {
    try {
      // بنبعت كل الـ history ما عدا الرسالة الترحيبية الأولى
      final conversationHistory = history
          .where((m) => !m.text.startsWith("Hello! I'm your Heart Health"))
          .map((m) => m.toGroqFormat())
          .toList();

      final Response response = await DioHelper.post(
        url: ApiEndpoints.chat,
        data: {
          'message': message,
          'conversationHistory': conversationHistory,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return data['message'] as String;
      }

      throw Exception('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorBody = e.response?.data;

      if (statusCode == 401) {
        throw Exception('Invalid API key. Please contact support.');
      } else if (statusCode == 429) {
        throw Exception('Too many requests. Please wait a moment and try again.');
      } else if (statusCode != null && errorBody != null) {
        final msg = errorBody['error'] ?? 'Server error';
        throw Exception(msg);
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server. Make sure the backend is running.');
      }

      throw Exception('Something went wrong. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
