import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../widgets/my_spending_summary.dart';

class MyPagePage extends ConsumerWidget {
  const MyPagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: BnkAppBar(
        title: '마이페이지',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).onLogout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          _ProfileSection(),
          const Divider(height: 1),
          const MySpendingSummary(),
          const Divider(height: 1),
          _MenuItem(
            icon: Icons.credit_card_outlined,
            title: '내 카드 관리',
            onTap: () {}, // TODO: 내 카드 페이지 연결
          ),
          _MenuItem(
            icon: Icons.bar_chart_outlined,
            title: '소비 패턴 등록/수정',
            onTap: () => context.go('/spending/input'),
          ),
          _MenuItem(
            icon: Icons.lock_outline,
            title: '비밀번호 변경',
            onTap: () {}, // TODO: 비밀번호 변경 페이지 연결
          ),
          _MenuItem(
            icon: Icons.smart_toy_outlined,
            title: 'AI 카드 추천',
            onTap: () => context.go('/ai/chat'),
          ),
        ],
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 3),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    child: Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor:
          AppColors.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.person,
              color: AppColors.primary, size: 36),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 계정',
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 4),
            Text('BNK 부산은행 카드',
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13)),
          ],
        ),
      ],
    ),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData    icon;
  final String      title;
  final VoidCallback onTap;
  const _MenuItem(
      {required this.icon,
        required this.title,
        required this.onTap});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: AppColors.primary),
    title: Text(title),
    trailing: const Icon(Icons.chevron_right,
        color: AppColors.textMuted),
    onTap: onTap,
  );
}