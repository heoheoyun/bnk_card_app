import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../providers/mypage_provider.dart';

class MyPagePage extends ConsumerWidget {
  const MyPagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myInfoAsync = ref.watch(myInfoProvider);
    final myCardsAsync = ref.watch(myCardsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.teal900,
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text('마이페이지',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: '로그아웃',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).onLogout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── 프로필 헤더 ──────────────────────────────────────
          Container(
            width: double.infinity,
            color: AppColors.teal900,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: myInfoAsync.when(
              loading: () => const SizedBox(
                height: 60,
                child: Center(child: CircularProgressIndicator(color: Colors.white70)),
              ),
              error: (_, __) => const Text('정보를 불러오지 못했습니다.',
                  style: TextStyle(color: Colors.white70)),
              data: (info) {
                final name = info['name'] ?? info['maskedName'] ?? '회원';
                final email = info['email'] ?? info['maskedEmail'] ?? '';
                return Row(
                  children: [
                    Container(
                      width: 52, height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.toString().isNotEmpty ? name.toString().substring(0, 1) : '?',
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('$name 님',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                          const SizedBox(height: 3),
                          Text(email.toString(),
                              style: const TextStyle(fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.chevron_right, color: Colors.white70),
                    ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ── 보유 카드 요약 ───────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('내 카드',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    TextButton(
                      onPressed: () => context.go('/search'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Row(
                        children: [
                          Text('카드 추가', style: TextStyle(fontSize: 12, color: AppColors.teal600)),
                          Icon(Icons.add, size: 14, color: AppColors.teal600),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                myCardsAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  ),
                  error: (_, __) => const Text('카드 정보를 불러오지 못했습니다.',
                      style: TextStyle(fontSize: 12, color: AppColors.gray400)),
                  data: (data) {
                    final owned = (data['ownedCards'] as List? ?? [])
                        .map((e) => Map<String, dynamic>.from(e as Map))
                        .toList();
                    if (owned.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Text('보유한 카드가 없습니다.',
                            style: TextStyle(fontSize: 12, color: AppColors.gray400)),
                      );
                    }
                    return Column(
                      children: owned.map((c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 24,
                                decoration: BoxDecoration(
                                  color: AppColors.teal800,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(c['cardName'] as String? ?? '카드',
                                    style: const TextStyle(fontSize: 13, color: AppColors.gray800)),
                              ),
                              const Icon(Icons.chevron_right, size: 16, color: AppColors.gray400),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── 메뉴 목록 ────────────────────────────────────────
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _MenuItem(
                  icon: Icons.bar_chart_outlined,
                  title: '소비 패턴 등록/수정',
                  onTap: () => context.go('/spending/input'),
                ),
                _MenuItem(
                  icon: Icons.lock_outline,
                  title: '비밀번호 변경',
                  onTap: () => _showChangePasswordSheet(context, ref),
                ),
                _MenuItem(
                  icon: Icons.person_outline,
                  title: '내 정보 수정',
                  onTap: () => _showEditInfoSheet(context, ref, myInfoAsync.valueOrNull),
                ),
                _MenuItem(
                  icon: Icons.smart_toy_outlined,
                  title: 'AI 카드 추천',
                  onTap: () => context.go('/ai/chat'),
                ),
                _MenuItem(
                  icon: Icons.fingerprint,
                  title: '생체인증 설정',
                  onTap: () {},
                  trailing: Switch(
                    value: false,
                    activeColor: AppColors.teal600,
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 3),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('비밀번호 변경',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            TextField(
              controller: currentCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: '현재 비밀번호'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: newCtrl,
              obscureText: true,
              decoration: const InputDecoration(hintText: '새 비밀번호'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final ds = ref.read(mypageDatasourceProvider);
                  try {
                    await ds.changePassword(currentCtrl.text, newCtrl.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('변경에 실패했습니다.')),
                      );
                    }
                  }
                },
                child: const Text('변경하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditInfoSheet(
      BuildContext context, WidgetRef ref, Map<String, dynamic>? info) {
    final nameCtrl = TextEditingController(text: info?['name'] as String? ?? '');
    final phoneCtrl = TextEditingController(text: info?['phone'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내 정보 수정',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: '이름'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              decoration: const InputDecoration(hintText: '휴대폰 번호'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  final ds = ref.read(mypageDatasourceProvider);
                  try {
                    await ds.updateMyInfo({
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                    });
                    ref.invalidate(myInfoProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('수정에 실패했습니다.')),
                      );
                    }
                  }
                },
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.gray100, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.gray600),
            const SizedBox(width: 14),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.gray800)),
            ),
            trailing ?? const Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}