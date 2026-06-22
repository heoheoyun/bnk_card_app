import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _newPwCtrl = TextEditingController();
  bool _isLoading = false;
  bool _requested = false;

  Future<void> _requestReset() async {
    if (_emailCtrl.text.trim().isEmpty || _nameCtrl.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.findPassword(_emailCtrl.text.trim(), _nameCtrl.text.trim());
      setState(() => _requested = true);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('인증 메일을 발송했습니다. 메일의 코드를 입력해주세요.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('일치하는 회원 정보를 찾을 수 없습니다.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    if (_tokenCtrl.text.trim().isEmpty || _newPwCtrl.text.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        _emailCtrl.text.trim(),
        _tokenCtrl.text.trim(),
        _newPwCtrl.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('비밀번호가 재설정되었습니다. 다시 로그인해주세요.')),
        );
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('재설정에 실패했습니다. 코드를 확인해주세요.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        title: const Text('비밀번호 재설정',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('이메일', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                enabled: !_requested,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('example@busanbank.co.kr'),
              ),
              const SizedBox(height: 16),

              const Text('이름', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                enabled: !_requested,
                decoration: _dec('홍길동'),
              ),

              if (!_requested) ...[
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _requestReset,
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
                        : const Text('인증 메일 발송',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 20),
                const Text('인증 코드', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _tokenCtrl,
                  decoration: _dec('메일로 받은 인증 코드'),
                ),
                const SizedBox(height: 16),

                const Text('새 비밀번호', style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                const SizedBox(height: 6),
                TextField(
                  controller: _newPwCtrl,
                  obscureText: true,
                  decoration: _dec('영문, 숫자, 특수문자 포함 8자 이상'),
                ),

                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
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
                        : const Text('비밀번호 재설정',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
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