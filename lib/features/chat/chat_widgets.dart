import 'package:flutter/material.dart';
import 'package:heart_disease/features/chat/chat_message_model.dart';
import 'package:heart_disease/res/app_colors.dart';


// ─────────────────────────────────────────────────────────
// MESSAGE BUBBLE
// ─────────────────────────────────────────────────────────
class ChatBubble extends StatelessWidget {
  final ChatMessageModel message;

  const ChatBubble({super.key, required this.message});

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
    final min = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $period';
  }

  @override
  Widget build(BuildContext context) {
    return message.isUser ? _userBubble() : _botBubble();
  }

  Widget _userBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15, height: 1.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _botBubble() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: const TextStyle(
                        color: Color(0xFF2D2D2D),
                        fontSize: 15,
                        height: 1.4),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// BOT AVATAR
// ─────────────────────────────────────────────────────────
class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child:  Image.asset(
            'assets/icons/bot.png',
            width: 22,
            height: 22,
            color: Colors.white,
            
          ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// TYPING INDICATOR (animated dots)
// ─────────────────────────────────────────────────────────
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      ),
    );
    _animations = _controllers.asMap().entries.map((e) {
      Future.delayed(Duration(milliseconds: e.key * 150), () {
        if (mounted) e.value.repeat(reverse: true);
      });
      return Tween<double>(begin: 0, end: -6).animate(
        CurvedAnimation(parent: e.value, curve: Curves.easeInOut),
      );
    }).toList();
  }

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BotAvatar(),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (i) {
                return AnimatedBuilder(
                  animation: _animations[i],
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _animations[i].value),
                    child: Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: const BoxDecoration(
                        color: Color(0xFF26A69A),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// QUICK QUESTIONS PANEL
// ─────────────────────────────────────────────────────────
class QuickQuestionsPanel extends StatelessWidget {
  final void Function(String) onTap;

  static const List<String> _questions = [
    'What foods are good for heart health?',
    'How can I lower my blood pressure?',
    'What are heart disease risk factors?',
    'How much exercise do I need?',
  ];

  const QuickQuestionsPanel({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick questions:',
            style: TextStyle(
                color: Color(0xFF757575),
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          ..._questions.map((q) => _QuickChip(label: q, onTap: onTap)),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final String label;
  final void Function(String) onTap;

  const _QuickChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GestureDetector(
        onTap: () => onTap(label),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Text(
            label,
            style: const TextStyle(
                color: Color(0xFF424242),
                fontSize: 14,
                fontWeight: FontWeight.w400),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// INPUT BAR
// ─────────────────────────────────────────────────────────
class ChatInputBar extends StatefulWidget {
  final void Function(String) onSend;
  final bool isLoading;

  const ChatInputBar({
    super.key,
    required this.onSend,
    required this.isLoading,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final TextEditingController _ctrl = TextEditingController();

  void _submit() {
    if (_ctrl.text.trim().isEmpty || widget.isLoading) return;
    widget.onSend(_ctrl.text.trim());
    _ctrl.clear();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _ctrl,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  // ✅ على Web — Enter يرسل، Shift+Enter سطر جديد
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _submit(),
                  enabled: !widget.isLoading,
                  style: const TextStyle(fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Ask about heart health...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _submit,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.isLoading
                      ? Colors.grey[300]
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send_rounded,
                  color: widget.isLoading ? Colors.grey : Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
