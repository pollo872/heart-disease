import 'package:easy_localization/easy_localization.dart';

class ChatMessageModel {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? fileType;   // 'image' | 'pdf' | null
  final String? fileName;   // اسم الملف للعرض

  ChatMessageModel({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.fileType,
    this.fileName,
  });

  bool get hasFile => fileType != null;
  bool get isImage => fileType == 'image';
  bool get isPdf => fileType == 'pdf';

  /// تحويل للـ format اللي الـ backend بيقبله في conversationHistory
  Map<String, dynamic> toGroqFormat() => {
        'role': isUser ? 'user' : 'assistant',
        'content': text,
      };

  factory ChatMessageModel.fromApi(String text) => ChatMessageModel(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      );

  factory ChatMessageModel.fromUser(String text) => ChatMessageModel(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      );

  /// رسالة مستخدم مع ملف
  factory ChatMessageModel.fromUserWithFile({
    required String text,
    required String fileType,
    required String fileName,
  }) =>
      ChatMessageModel(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
        fileType: fileType,
        fileName: fileName,
      );

  factory ChatMessageModel.greeting() => ChatMessageModel(
        text:
            "Hello I'm your Heart Health Assistant".tr(),
        isUser: false,
        timestamp: DateTime.now(),
      );
}