// IP 2단계 인증 화면 (이메일 코드).
// 로그인 응답이 requireIpVerify=true 일 때 '/ip-verify' 로 진입.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class IpVerifyArgs {
  final int userId;
  final String challengeToken;
  final List<String> methods;
  const IpVerifyArgs({
    required this.userId,
    required this.challengeToken,
    required this.methods,
  });
}

class IpVerifyPage extends ConsumerStatefulWidget {
  final IpVerifyArgs args;
  const IpVerifyPage({super.key, required this.args});

  @override
  ConsumerState<IpVerifyPage> createState() => _IpVerifyPageState();
}

class _IpVerifyPageState extends ConsumerState<IpVerifyPage> {
  final _codeCtrl = TextEditingController();
  bool _sent = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    // 진입 즉시 코드 1회 발송
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendCode());
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).sendIpEmailCode(
        userId: widget.args.userId,
        challengeToken: widget.args.challengeToken,
      );
      if (!mounted) return;
      setState(() => _sent = true);
      _snack('인증 코드를 이메일로 보냈습니다. (10분 유효)');
    } catch (_) {
      _snack('인증 코드 발송에 실패했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirm() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _snack('인증 코드를 입력해 주세요.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).confirmIpEmailCode(
        userId: widget.args.userId,
        challengeToken: widget.args.challengeToken,
        code: code,
        nickname: '내 기기',
      );
      if (!mounted) return;
      context.go('/');
    } catch (_) {
      if (!mounted) return;
      _snack('인증에 실패했습니다. 코드를 확인해 주세요.');
      setState(() => _busy = false);
    }
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.gray800,
        title: const Text('기기 인증', style: TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.shield_outlined,
                  size: 40, color: AppColors.teal600),
              const SizedBox(height: 16),
              const Text('새로운 기기에서 로그인했어요',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text(
                '안전을 위해 가입하신 이메일로 보낸 인증 코드를 입력해 주세요.',
                style: TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
              const SizedBox(height: 32),
              const Text('인증 코드',
                  style: TextStyle(fontSize: 12, color: AppColors.gray600)),
              const SizedBox(height: 6),
              TextField(
                controller: _codeCtrl,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _confirm(),
                decoration: InputDecoration(
                  hintText: '6자리 코드',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.teal600),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _busy ? null : _sendCode,
                  child: Text(_sent ? '코드 재전송' : '코드 받기',
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.teal600)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _busy ? null : _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _busy
                      ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                      : const Text('인증하고 로그인',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('다른 계정으로 로그인',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.gray600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}