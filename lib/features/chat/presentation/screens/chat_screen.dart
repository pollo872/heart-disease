import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/chat/presentation/manager/chat_cubit.dart';
import 'package:heart_disease/features/chat/presentation/manager/chat_state.dart';
import 'package:heart_disease/features/chat/presentation/widgets/chat_widgets.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_bloc.dart';
import 'package:heart_disease/features/main_pages/presentation/manager/main_event.dart';
import 'package:heart_disease/features/main_pages/presentation/widgets/profile_image.dart';
import 'package:heart_disease/theme/app_theme.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ChatView();
  }
}

class _ChatView extends StatefulWidget {
  const _ChatView();

  @override
  State<_ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<_ChatView> {
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSend(String text) {
    context.read<ChatCubit>().sendMessage(text);
  }

  void _onSendFile({
    required Uint8List fileBytes,
    required String mimeType,
    required String fileName,
    required String message,
  }) {
    context.read<ChatCubit>().sendMessageWithFile(
          message: message,
          fileBytes: fileBytes,
          mimeType: mimeType,
          fileName: fileName,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          _scrollToBottom();
          if (state is ChatError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red[400],
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          final messages = _getMessages(state);
          final isLoading = state is ChatLoading;
          final showQuickQ = messages.length == 1;

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  itemCount: messages.length + (isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const TypingIndicator();
                    }
                    return ChatBubble(message: messages[index]);
                  },
                ),
              ),
              if (showQuickQ) QuickQuestionsPanel(onTap: _onSend),
              // ✅ onSendFile متربط بالـ cubit
              ChatInputBar(
                onSend: _onSend,
                onSendFile: _onSendFile,
                isLoading: isLoading,
              ),
            ],
          );
        },
      ),
    );
  }

  List _getMessages(ChatState state) {
    if (state is ChatInitial) return state.messages;
    if (state is ChatLoading) return state.messages;
    if (state is ChatSuccess) return state.messages;
    if (state is ChatError) return state.messages;
    return [];
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      scrolledUnderElevation: 0,
      elevation: 0.5,
      leadingWidth: 50,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            context.read<MainBloc>().add(MainTabChangedEvent(4));
          },
          child: ProfileImage(),
        ),
      ),
      title: const Text(
        'chat',
        style: AppTextStyles.pageTitle,
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_none,
            color: AppColors.pageTitle,
            size: 25,
          ),
          tooltip: 'Notifications',
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.pageTitle),
          tooltip: 'New conversation',
          onPressed: () => context.read<ChatCubit>().resetChat(),
        ),
      ],
    );
  }
}
