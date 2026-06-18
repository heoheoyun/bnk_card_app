import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';
import '../providers/auth_provider.dart';

class FindIdPage extends ConsumerStatefulWidget {
  const FindIdPage({super.key});

  @override
  ConsumerState<FindIdPage> createState() => _FindIdPageState();
}

class _FindIdPageState extends ConsumerState<FindIdPage> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool    _isLoading  = false;
  String? _foundEmail;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _findId() async {
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim().replaceAll('-', '');
    if (name.isEmpty || phone.isEmpty) {
      _snack('이름과 전화번호를 모두 입력해 주세요.', error: true);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result =
      await ref.read(authRepositoryProvider).findId(name, phone);
      setState(() => _foundEmail = result['maskedEmail']);
    } catch (_) {
      _snack('가입된 계정을 찾을 수 없습니다.', error: true);
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
      appBar: const BnkAppBar(title: '아이디 찾기'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _foundEmail == null ? _buildForm() : _buildResult(),
      ),
    );
  }

  Widget _buildForm() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Text(
        '가입 시 등록한 이름과\n휴대전화 번호를 입력해 주세요.',
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
      const SizedBox(height: 32),
      TextField(
        controller: _nameCtrl,
        decoration: const InputDecoration(
          labelText: '이름',
          prefixIcon: Icon(Icons.person_outline),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: '휴대전화 번호',
          hintText: '010-0000-0000',
          prefixIcon: Icon(Icons.phone_outlined),
        ),
      ),
      const SizedBox(height: 32),
      BnkButton(
        label: '아이디 찾기',
        isLoading: _isLoading,
        onPressed: _findId,
      ),
    ],
  );

  Widget _buildResult() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Icon(Icons.check_circle_outline,
          size: 64, color: AppColors.primary),
      const SizedBox(height: 24),
      const Text(
        '아이디 찾기 완료',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2)),
        ),
        child: Text(
          _foundEmail!,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary),
          textAlign: TextAlign.center,
        ),
      ),
      const SizedBox(height: 32),
      BnkButton(
        label: '로그인하기',
        onPressed: () => context.go('/login'),
      ),
      const SizedBox(height: 12),
      OutlinedButton(
        onPressed: () => context.go('/reset-password'),
        child: const Text('비밀번호 재설정'),
      ),
    ],
  );
}