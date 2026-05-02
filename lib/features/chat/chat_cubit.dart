import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/chat/chat_message_model.dart';
import 'package:heart_disease/features/chat/chat_repository.dart';

import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _repository;

  ChatCubit(this._repository)
      : super(ChatInitial([ChatMessageModel.greeting()]));

  /// Getter مريح للوصول للـ messages من أي state
  List<ChatMessageModel> get _currentMessages {
    final s = state;
    if (s is ChatInitial) return s.messages;
    if (s is ChatLoading) return s.messages;
    if (s is ChatSuccess) return s.messages;
    if (s is ChatError) return s.messages;
    return [];
  }

  /// ترسل رسالة المستخدم وتجيب رد الـ AI
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // ✅ نضيف رسالة المستخدم فوراً
    final userMsg = ChatMessageModel.fromUser(text.trim());
    final updatedMessages = [..._currentMessages, userMsg];

    emit(ChatLoading(updatedMessages));

    try {
      final reply = await _repository.sendMessage(
        message: text.trim(),
        history: updatedMessages,
      );

      final botMsg = ChatMessageModel.fromApi(reply);
      emit(ChatSuccess([...updatedMessages, botMsg]));
    } catch (e) {
      // ✅ في حالة error نضيف رسالة خطأ من الـ bot
      final errorMsg = ChatMessageModel.fromApi(
        e.toString().replaceFirst('Exception: ', ''),
      );
      emit(ChatError(
        messages: [...updatedMessages, errorMsg],
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  /// إعادة ضبط المحادثة من الأول
  void resetChat() {
    emit(ChatInitial([ChatMessageModel.greeting()]));
  }
}
