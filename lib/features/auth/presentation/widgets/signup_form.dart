import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/bnk_button.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final _emailCtrl    = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _emailVerified = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendVerifyCode() async {
    try {
      await ref
          .read(authRepositoryProvider)
          .sendVerifyCode(_emailCtrl.text.trim());
      if (mounted) context.go('/signup/verify');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(children: [
        Expanded(
          child: TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: '이메일'),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          onPressed: _emailVerified ? null : _sendVerifyCode,
          child: Text(_emailVerified ? '인증완료' : '인증'),
        ),
      ]),
      const SizedBox(height: 12),
      TextField(
        controller: _nameCtrl,
        decoration: const InputDecoration(labelText: '이름'),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _phoneCtrl,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(
          labelText: '전화번호',
          hintText: '010-0000-0000',
        ),
      ),
      const SizedBox(height: 12),
      TextField(
        controller: _passwordCtrl,
        obscureText: true,
        decoration: const InputDecoration(labelText: '비밀번호'),
      ),
      const SizedBox(height: 24),
      BnkButton(
        label: '약관 동의 후 가입하기',
        onPressed: _emailVerified ? () => context.go('/terms/SIGNUP') : null,
      ),
    ],
  );
}