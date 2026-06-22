import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class SignupVerifyPage extends ConsumerStatefulWidget {
  final String? email;
  const SignupVerifyPage({super.key, this.email});

  @override
  ConsumerState<SignupVerifyPage> createState() => _SignupVerifyPageState();
}

class _SignupVerifyPageState extends ConsumerState<SignupVerifyPage> {
  final _codeCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;

  Future<void> _verify() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.verifyEmail(widget.email ?? '', _codeCtrl.text.trim());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증이 완료되었습니다. 로그인해주세요.')),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증번호가 올바르지 않습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _isResending = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.sendVerifyCode(widget.email ?? '');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증번호를 재발송했습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.gray800,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: AppColors.teal50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.mark_email_read_outlined,
                    color: AppColors.teal600, size: 28),
              ),
              const SizedBox(height: 20),
              const Text('이메일 인증',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text(
                '${widget.email ?? ''} 으로\n발송된 인증번호 6자리를 입력해주세요',
                style: const TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.5),
              ),
              const SizedBox(height: 28),

              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, letterSpacing: 8, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.teal600, width: 1.2),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _isResending ? null : _resend,
                  child: Text(_isResending ? '발송중...' : '인증번호 재발송',
                      style: const TextStyle(fontSize: 12, color: AppColors.teal600)),
                ),
              ),

              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 18, height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('인증 완료',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}