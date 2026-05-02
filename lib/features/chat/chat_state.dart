

import 'package:heart_disease/features/chat/chat_message_model.dart';

abstract class ChatState {}

/// الحالة الأولى — بتُبنى فيها قائمة الرسائل مع الرسالة الترحيبية
class ChatInitial extends ChatState {
  final List<ChatMessageModel> messages;
  ChatInitial(this.messages);
}

/// المستخدم بعت رسالة والـ AI بيرد
class ChatLoading extends ChatState {
  final List<ChatMessageModel> messages;
  ChatLoading(this.messages);
}

/// وصل الرد بنجاح
class ChatSuccess extends ChatState {
  final List<ChatMessageModel> messages;
  ChatSuccess(this.messages);
}

/// حصل error
class ChatError extends ChatState {
  final List<ChatMessageModel> messages;
  final String errorMessage;
  ChatError({required this.messages, required this.errorMessage});
}
