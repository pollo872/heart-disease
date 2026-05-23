import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:heart_disease/core/network/api_endpoints.dart';
import 'package:heart_disease/core/network/dio_helper.dart';
import 'package:heart_disease/features/chat/data/models/chat_message_model.dart';

class ChatRepository {
  /// إرسال رسالة نصية فقط → Groq
  Future<String> sendMessage({
    required String message,
    required List<ChatMessageModel> history,
  }) async {
    return _send(
      message: message,
      history: history,
    );
  }

  /// إرسال رسالة مع صورة أو PDF → Claude
  Future<String> sendMessageWithFile({
    required String message,
    required List<ChatMessageModel> history,
    required Uint8List fileBytes,
    required String mimeType, // 'image/jpeg' | 'image/png' | 'application/pdf'
  }) async {
    final base64Data = base64Encode(fileBytes);
    return _send(
      message: message,
      history: history,
      fileData: base64Data,
      fileType: mimeType,
    );
  }

  Future<String> _send({
    required String message,
    required List<ChatMessageModel> history,
    String? fileData,
    String? fileType,
  }) async {
    try {
      final conversationHistory = history
          .where((m) =>
              !m.text.startsWith("Hello! I'm your Heart Health") && !m.isUser || m.isUser)
          .where((m) => !m.text.startsWith("Hello! I'm your Heart Health"))
          .map((m) => m.toGroqFormat())
          .toList();

      final Map<String, dynamic> body = {
        'message': message,
        'conversationHistory': conversationHistory,
      };

      if (fileData != null && fileType != null) {
        body['fileData'] = fileData;
        body['fileType'] = fileType;
      }

      final Response response = await DioHelper.post(
        url: ApiEndpoints.chat,
        data: body,
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['message'] as String;
      }

      throw Exception('Unexpected response: ${response.statusCode}');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final errorBody = e.response?.data;

      if (statusCode == 401) {
        throw Exception('Invalid API key. Please contact support.');
      } else if (statusCode == 429) {
        throw Exception('Too many requests. Please wait and try again.');
      } else if (statusCode != null && errorBody != null) {
        throw Exception(errorBody['error'] ?? 'Server error');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Connection timed out. Please check your internet.');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Cannot connect to server.');
      }

      throw Exception('Something went wrong. Please try again.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}