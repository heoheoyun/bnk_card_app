import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';
import '../providers/auth_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() =>
      _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl  = TextEditingController();
  bool _isLoading  = false;
  bool _sent       = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _request() async {
    final email = _emailCtrl.text.trim();
    final name  = _nameCtrl.text.trim();
    if (email.isEmpty || name.isEmpty) {
      _snack('이메일과 이름을 모두 입력해 주세요.', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).findPassword(email, name);
      setState(() => _sent = true);
    } catch (_) {
      _snack('입력한 정보와 일치하는 계정이 없습니다.', error: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: error ? Colors.red : AppColors.primary,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BnkAppBar(title: '비밀번호 재설정'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent ? _buildDone() : _buildForm(),
      ),
    );
  }

  Widget _buildForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        '가입하신 이메일 주소와 이름을 입력하면\n비밀번호 재설정 링크를 보내드립니다.',
        style: TextStyle(
            fontSize: 15,
            height: 1.6,
            color: AppColors.textMuted),
      ),
      const SizedBox(height: 32),
      TextField(
        controller: _emailCtrl,
        keyboardType: TextInputType.emailAddress,
        decoration: const InputDecoration(
          labelText: '이메일',
          prefixIcon: Icon(Icons.email_outlined),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _nameCtrl,
        decoration: const InputDecoration(
          labelText: '이름',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      const SizedBox(height: 32),
      BnkButton(
        label: '재설정 링크 보내기',
        isLoading: _isLoading,
        onPressed: _request,
      ),
    ],
  );

  Widget _buildDone() => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.forward_to_inbox_outlined,
          size: 72, color: AppColors.primary),
      const SizedBox(height: 24),
      const Text(
        '이메일을 확인해 주세요',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 12),
      Text(
        '${_emailCtrl.text} 으로\n비밀번호 재설정 링크를 보냈습니다.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: AppColors.textMuted, height: 1.6),
      ),
      const SizedBox(height: 40),
      BnkButton(
        label: '로그인으로 돌아가기',
        onPressed: () => context.go('/login'),
      ),
    ],
  );
}