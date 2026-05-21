import 'package:easy_localization/easy_localization.dart';

class ChatMessageModel {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  /// تحويل للـ format اللي الـ backend بيقبله في conversationHistory
  Map<String, dynamic> toGroqFormat() => {
        'role': isUser ? 'user' : 'assistant',
        'content': text,
      };

  /// Factory من response الـ API
  factory ChatMessageModel.fromApi(String text) => ChatMessageModel(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );

  /// رسالة المستخدم
  factory ChatMessageModel.fromUser(String text) => ChatMessageModel(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  /// الرسالة الترحيبية الأولى
  factory ChatMessageModel.greeting() => ChatMessageModel(
        text:
            "Hello I'm your Heart Health Assistant".tr(),
        isUser: false,
        timestamp: DateTime.now(),
      );
}
