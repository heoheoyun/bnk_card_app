import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';
import '../providers/auth_provider.dart';

/// 이메일 인증 코드 확인 페이지.
///
/// SignupForm 에서 이메일 인증 발송 후 이 페이지로 이동한다.
/// 이메일은 GoRouter extra 또는 쿼리파라미터로 전달받는다.
///
/// 현재는 쿼리파라미터 방식 사용: /signup/verify?email=xxx@yyy.com
class SignupVerifyPage extends ConsumerStatefulWidget {
  const SignupVerifyPage({super.key});

  @override
  ConsumerState<SignupVerifyPage> createState() => _SignupVerifyPageState();
}

class _SignupVerifyPageState extends ConsumerState<SignupVerifyPage> {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  String? get _email {
    // GoRouterState 쿼리파라미터에서 email 추출
    final uri = Uri.base;
    return uri.queryParameters['email'];
  }

  Future<void> _verify() async {
    final code  = _codeCtrl.text.trim();
    final email = _email ?? '';

    if (code.length != 6) {
      _snack('6자리 인증 코드를 입력해 주세요.', error: true);
      return;
    }
    if (email.isEmpty) {
      _snack('이메일 정보가 없습니다. 다시 시도해 주세요.', error: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).verifyEmail(email, code);
      if (mounted) {
        _snack('이메일 인증이 완료되었습니다.');
        context.go('/signup');
      }
    } catch (e) {
      _snack('인증 코드가 올바르지 않습니다.', error: true);
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
      appBar: const BnkAppBar(title: '이메일 인증'),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_read_outlined,
                size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              '인증 코드를 입력하세요',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '가입 이메일로 발송된 6자리 코드를 입력해 주세요.\n코드는 5분간 유효합니다.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _codeCtrl,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 8),
              decoration: InputDecoration(
                hintText: '------',
                hintStyle: TextStyle(
                    color: Colors.grey.shade300, letterSpacing: 8),
                counterText: '',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            BnkButton(
              label: '인증 확인',
              isLoading: _isLoading,
              onPressed: _verify,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('이전으로 돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}