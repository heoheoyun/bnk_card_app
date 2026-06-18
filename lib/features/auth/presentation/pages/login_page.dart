import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(Icons.credit_card,
                          color: Colors.white, size: 40),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'BNK 카드',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '부산은행 카드 서비스',
                      style: TextStyle(
                          fontSize: 14, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const LoginForm(),
            ],
          ),
        ),
      ),
    );
  }
}