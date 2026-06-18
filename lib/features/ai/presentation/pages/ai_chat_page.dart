import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../../data/models/chat_message_model.dart';
import '../providers/chat_provider.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key});

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  final _ctrl       = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    ref.read(chatProvider.notifier).sendMessage(text);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen<ChatState>(chatProvider, (_, __) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom());
    });

    return Scaffold(
      appBar: BnkAppBar(
        title: 'BNK AI 카드 추천',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: '대화 초기화',
            onPressed: () =>
                ref.read(chatProvider.notifier).clearChat(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildWelcome()
                : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 12),
              itemCount: chatState.messages.length +
                  (chatState.isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == chatState.messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(
                    message: chatState.messages[i]);
              },
            ),
          ),
          _InputBar(
            controller: _ctrl,
            isLoading: chatState.isLoading,
            onSend: _send,
          ),
        ],
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 2),
    );
  }

  Widget _buildWelcome() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy_outlined,
              size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 20),
        const Text('BNK AI 카드 어시스턴트',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          '소비 패턴에 맞는 카드를 추천해 드립니다.\n궁금한 점을 자유롭게 질문해 보세요!',
          textAlign: TextAlign.center,
          style:
          TextStyle(color: AppColors.textMuted, height: 1.5),
        ),
      ],
    ),
  );
}

// ── 메시지 버블 ─────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _MessageBubble({required this.message});

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
      _isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(
            horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: _isUser ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(_isUser ? 16 : 4),
            bottomRight: Radius.circular(_isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: _isUser ? Colors.white : AppColors.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(
          horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox(
        width: 40,
        child: LinearProgressIndicator(minHeight: 2),
      ),
    ),
  );
}

// ── 입력창 ───────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  const _InputBar(
      {required this.controller,
        required this.isLoading,
        required this.onSend});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border:
          Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: !isLoading,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                maxLines: null,
                decoration: InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isLoading ? null : onSend,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLoading
                      ? Colors.grey.shade300
                      : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLoading
                      ? Icons.hourglass_empty
                      : Icons.send_rounded,
                  color: Colors.white,
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