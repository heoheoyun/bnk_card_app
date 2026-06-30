import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../../../../shared/widgets/home_back_scope.dart';
import '../../data/models/chat_message_model.dart';
import '../providers/chat_provider.dart';

const _aiAvatarUrl =
    'https://objectstorage.ap-chuncheon-1.oraclecloud.com/n/axa1llzzkj5q/b/terms/o/images%2Fimageshachi-fotor-2026052617514.png';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    return HomeBackScope(
      child: Scaffold(
      backgroundColor: AppColors.background,
      appBar: BnkAppBar(
        title: 'AI 카드 추천',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: '대화 초기화',
            onPressed: () => ref.read(chatProvider.notifier).clearChat(),
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
                  horizontal: 16, vertical: 16),
              itemCount: chatState.messages.length +
                  (chatState.isLoading ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == chatState.messages.length) {
                  return const _TypingIndicator();
                }
                return _MessageBubble(message: chatState.messages[i]);
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
      ),
    );
  }

  Widget _buildWelcome() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipOval(
          child: CachedNetworkImage(
            imageUrl: _aiAvatarUrl,
            width: 80, height: 80,
            fit: BoxFit.cover,
            placeholder: (_, __) => Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                  color: AppColors.teal50, shape: BoxShape.circle),
            ),
            errorWidget: (_, __, ___) => Container(
              width: 80, height: 80,
              decoration: const BoxDecoration(
                  color: AppColors.teal50, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_outlined,
                  size: 44, color: AppColors.teal600),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('BNK AI 카드 어시스턴트',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.gray800)),
        const SizedBox(height: 8),
        const Text(
          '소비 패턴에 맞는 카드를 추천해 드립니다.\n궁금한 점을 자유롭게 질문해 보세요!',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 13, color: AppColors.gray400, height: 1.6),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 8, runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            '카드 추천해줘',
            '연회비 없는 카드',
            '주유 혜택 카드',
            '체크카드 추천',
          ].map((q) => GestureDetector(
            onTap: () {
              _ctrl.text = q;
              _send();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.teal200),
              ),
              child: Text(q,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.teal600)),
            ),
          )).toList(),
        ),
      ],
    ),
  );
}

// ── AI 아바타 위젯 ────────────────────────────────────────────────
class _AiAvatar extends StatelessWidget {
  final double size;
  const _AiAvatar({this.size = 32});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: _aiAvatarUrl,
        width: size, height: size,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => Container(
          width: size, height: size,
          decoration: const BoxDecoration(
              color: AppColors.teal600, shape: BoxShape.circle),
          child: Icon(Icons.smart_toy_outlined,
              size: size * 0.5, color: Colors.white),
        ),
      ),
    );
  }
}

// ── 메시지 버블 ─────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessageModel message;
  const _MessageBubble({required this.message});

  bool get _isUser => message.role == ChatRole.user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
        _isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!_isUser) ...[
            const Padding(
              padding: EdgeInsets.only(right: 8, bottom: 2),
              child: _AiAvatar(size: 32),
            ),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.72),
              decoration: BoxDecoration(
                color: _isUser ? AppColors.teal600 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft:     const Radius.circular(16),
                  topRight:    const Radius.circular(16),
                  bottomLeft:  Radius.circular(_isUser ? 16 : 4),
                  bottomRight: Radius.circular(_isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: _isUser ? Colors.white : AppColors.gray800,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
          if (_isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: AppColors.teal100,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.person_outline,
                  size: 16, color: AppColors.teal600),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 타이핑 인디케이터 ────────────────────────────────────────────

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        const Padding(
          padding: EdgeInsets.only(right: 8, bottom: 2),
          child: _AiAvatar(size: 32),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft:     Radius.circular(16),
              topRight:    Radius.circular(16),
              bottomRight: Radius.circular(16),
              bottomLeft:  Radius.circular(4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) => _Dot(delay: i * 300)),
          ),
        ),
      ],
    ),
  );
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    // Total cycle = 1200ms so each 400ms-wide interval gets an equal share
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    final start = widget.delay / 1200;
    final end   = (widget.delay + 400) / 1200;
    _anim = Tween(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: Interval(start, end, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 2),
    child: FadeTransition(
      opacity: _anim,
      child: Container(
        width: 7, height: 7,
        decoration: const BoxDecoration(
          color: AppColors.gray400,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

// ── 입력창 ───────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;
  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
              top: BorderSide(color: AppColors.gray200, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
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
                  hintText: '카드에 대해 무엇이든 물어보세요',
                  hintStyle: const TextStyle(
                      fontSize: 13, color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.gray100,
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
                width: 44, height: 44,
                decoration: BoxDecoration(
                  color: isLoading ? AppColors.gray200 : AppColors.teal600,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLoading ? Icons.hourglass_empty : Icons.send_rounded,
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