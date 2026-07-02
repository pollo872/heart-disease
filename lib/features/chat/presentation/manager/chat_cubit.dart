import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/core/utils/error_message_handler.dart';
import 'package:heart_disease/features/chat/data/models/chat_message_model.dart';
import 'package:heart_disease/features/chat/data/repo/chat_repository.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository)
      : super(ChatInitial([ChatMessageModel.greeting()]));

  List<ChatMessageModel> get _currentMessages {
    final s = state;
    if (s is ChatInitial) return s.messages;
    if (s is ChatLoading) return s.messages;
    if (s is ChatSuccess) return s.messages;
    if (s is ChatError) return s.messages;
    return [];
  }

  /// ✉️ إرسال رسالة نصية فقط
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessageModel.fromUser(text.trim());
    final updatedMessages = [..._currentMessages, userMsg];
    emit(ChatLoading(updatedMessages));

    try {
      final reply = await _repository.sendMessage(
        message: text.trim(),
        history: updatedMessages,
      );
      emit(ChatSuccess([...updatedMessages, ChatMessageModel.fromApi(reply)]));
    } catch (e) {
      _handleError(e, updatedMessages);
    }
  }

  /// 📎 إرسال رسالة مع صورة أو PDF
  Future<void> sendMessageWithFile({
    required String message,
    required Uint8List fileBytes,
    required String mimeType,
    required String fileName,
  }) async {
    // نحدد نوع الملف للعرض في الـ bubble
    final displayType = mimeType == 'application/pdf' ? 'pdf' : 'image';

    final userMsg = ChatMessageModel.fromUserWithFile(
      text: message.isNotEmpty ? message : '📎 $fileName',
      fileType: displayType,
      fileName: fileName,
    );

    final updatedMessages = [..._currentMessages, userMsg];
    emit(ChatLoading(updatedMessages));

    try {
      final reply = await _repository.sendMessageWithFile(
        message: message.isNotEmpty
            ? message
            : 'Please analyze this medical ${displayType == 'pdf' ? 'document' : 'image'} and provide a detailed heart health report.',
        history: _currentMessages,
        fileBytes: fileBytes,
        mimeType: mimeType,
      );
      emit(ChatSuccess([...updatedMessages, ChatMessageModel.fromApi(reply)]));
    } catch (e) {
      _handleError(e, updatedMessages);
    }
  }

  void _handleError(Object e, List<ChatMessageModel> messages) {
    final errorMsg = ChatMessageModel.fromApi(
      ErrorMessageHandler.getMessage(e).replaceFirst('Exception: ', ''),
    );
    emit(ChatError(
      messages: [...messages, errorMsg],
      errorMessage: ErrorMessageHandler.getMessage(e).replaceFirst('Exception: ', ''),
    ));
  }

  void resetChat() {
    emit(ChatInitial([ChatMessageModel.greeting()]));
  }
}