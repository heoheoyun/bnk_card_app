import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _pwCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('이메일과 비밀번호를 입력해주세요.')),
      );
      return;
    }
    await ref.read(authProvider.notifier).login(
      _emailCtrl.text.trim(),
      _pwCtrl.text,
    );
    final state = ref.read(authProvider);
    if (state.hasError && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다. 이메일/비밀번호를 확인해주세요.')),
      );
    } else if (mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.arrow_back, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'BNK 부산은행',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.teal600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                '로그인',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 32),

              const Text('이메일',
                  style: TextStyle(fontSize: 12, color: AppColors.gray600)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration(hint: 'example@busanbank.co.kr'),
              ),
              const SizedBox(height: 18),

              const Text('비밀번호',
                  style: TextStyle(fontSize: 12, color: AppColors.gray600)),
              const SizedBox(height: 6),
              TextField(
                controller: _pwCtrl,
                obscureText: _obscure,
                onSubmitted: (_) => _login(),
                decoration: _inputDecoration(hint: '비밀번호 입력').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      size: 18, color: AppColors.gray400,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('로그인',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () => context.go('/find-id'),
                    child: const Text('아이디 찾기',
                        style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                  ),
                  const Text('|', style: TextStyle(color: AppColors.gray200)),
                  TextButton(
                    onPressed: () => context.go('/reset-password'),
                    child: const Text('비밀번호 재설정',
                        style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Row(
                children: const [
                  Expanded(child: Divider(color: AppColors.gray200)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('또는', style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                  ),
                  Expanded(child: Divider(color: AppColors.gray200)),
                ],
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/signup'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal600,
                    side: const BorderSide(color: AppColors.teal600),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('회원가입',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
      filled: true,
      fillColor: AppColors.gray100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.teal600, width: 1.2),
      ),
    );
  }
}