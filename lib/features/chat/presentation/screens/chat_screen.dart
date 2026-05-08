import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heart_disease/features/chat/presentation/manager/chat_cubit.dart';
import 'package:heart_disease/features/chat/data/repo/chat_repository.dart';
import 'package:heart_disease/features/chat/presentation/manager/chat_state.dart';
import 'package:heart_disease/features/chat/presentation/widgets/chat_widgets.dart';

// ─────────────────────────────────────────────────────────
// ENTRY POINT — يفتحها من أي مكان في التطبيق
// ─────────────────────────────────────────────────────────
class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ChatView();
  }
}

// ─────────────────────────────────────────────────────────
// MAIN VIEW
// ─────────────────────────────────────────────────────────
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatCubit, ChatState>(
        listener: (context, state) {
          // نسكرول لتحت كل ما تيجي حالة جديدة
          _scrollToBottom();

          // نبيّن snackbar لو حصل error
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
          final showQuickQ = messages.length == 1; // بس أول رسالة الـ greeting

          return Column(
            children: [
              // ── Messages ──
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

              // ── Quick Questions (أول مرة بس) ──
              if (showQuickQ) QuickQuestionsPanel(onTap: _onSend),

              // ── Input Bar ──
              ChatInputBar(
                onSend: _onSend,
                isLoading: isLoading,
              ),
            ],
          );
        },
      ),
      // bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Helpers ───────────────────────────────

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
      elevation: 0.5,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: const Icon(Icons.person, color: Colors.grey, size: 20),
        ),
      ),
      title: const Text(
        'chat',
        style: TextStyle(
            color: Colors.black, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black),
          onPressed: () {},
        ),
        // زرار لإعادة ضبط المحادثة
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.grey),
          tooltip: 'New conversation',
          onPressed: () => context.read<ChatCubit>().resetChat(),
        ),
      ],
    );
  }

  // BottomNavigationBar _buildBottomNav() {
  //   return BottomNavigationBar(
  //     currentIndex: 3,
  //     selectedItemColor: const Color(0xFF26A69A),
  //     unselectedItemColor: Colors.grey,
  //     showSelectedLabels: true,
  //     showUnselectedLabels: true,
  //     type: BottomNavigationBarType.fixed,
  //     items: const [
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.history),
  //         label: 'History',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.medical_services_outlined),
  //         label: 'Doctors',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.article_outlined),
  //         label: 'Articles',
  //       ),
  //       BottomNavigationBarItem(
  //         icon: Icon(Icons.chat_bubble_outline),
  //         label: 'Chat',
  //       ),
  //     ],
  //     onTap: (index) {
  //       // ربطها بالـ navigation بتاعك
  //     },
  //   );
  // }
}
