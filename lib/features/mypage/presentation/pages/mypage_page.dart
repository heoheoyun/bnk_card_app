// 마이페이지 — 재설계본.
//  - 동작하는 기능만 깔끔한 그룹으로 재구성
//      프로필 → 내 카드(보유/신청) → 계정 → 금융 → 알림
//  - 죽은 항목(신용점수·소득정보)과 중복 생체 토글 제거
//      (생체인증은 '간편로그인 설정' 화면이 단일 관리)
//  - 보유 카드는 표시 전용(탭 불가)
//  - SafeArea + 하단 인셋 패딩으로 시스템 버튼 가림 방지

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/push/push_service.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../providers/mypage_provider.dart';



class MyPagePage extends ConsumerStatefulWidget {
  const MyPagePage({super.key});

  @override
  ConsumerState<MyPagePage> createState() => _MyPagePageState();
}

class _MyPagePageState extends ConsumerState<MyPagePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  bool _pushEnabled = true;
  bool _marketingEnabled = false;
  bool _seeded = false; // 서버값 1회 동기화

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ── 빌드 ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final myInfoAsync = ref.watch(myInfoProvider);
    final myCardsAsync = ref.watch(myCardsProvider);

    final info = myInfoAsync.valueOrNull ?? const <String, dynamic>{};
    if (!_seeded && myInfoAsync.hasValue) {
      _pushEnabled = (info['pushEnabled'] as String? ?? 'Y') == 'Y';
      _marketingEnabled = (info['marketingAgree'] as String? ?? 'N') == 'Y';
      _seeded = true;
    }

    final name = info['name'] as String? ?? '';
    final maskedEmail =
        info['maskedEmail'] as String? ?? info['email'] as String? ?? '';
    final maskedPhone = info['maskedPhone'] as String? ?? '';
    final initial = name.isNotEmpty ? name.substring(0, 1) : '?';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BnkAppBar(
        title: '마이페이지',
        showBack: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white, size: 20),
            tooltip: '로그아웃',
            onPressed: () async {
              await ref.read(authStateProvider.notifier).onLogout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        bottom: false, // 하단 탭바는 bottomNavigationBar 가 별도 처리
        child: ListView(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          children: [
            // ── 프로필 헤더 ──────────────────────────────────────
            _ProfileHeader(
              loading: myInfoAsync.isLoading,
              initial: initial,
              name: name,
              maskedEmail: maskedEmail,
              maskedPhone: maskedPhone,
            ),

            const SizedBox(height: 12),

            // ── 내 카드 ─────────────────────────────────────────
            _Section(
              title: '내 카드',
              child: _MyCardsCard(
                tabController: _tabController,
                cardsAsync: myCardsAsync,
              ),
            ),

            // ── 계정 ────────────────────────────────────────────
            _Section(
              title: '계정',
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.person_outline,
                    title: '내 정보 수정',
                    subtitle: '이름·전화번호 변경',
                    onTap: () => _showEditInfoSheet(context, info),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.lock_outline,
                    title: '비밀번호 변경',
                    subtitle: '현재 비밀번호 확인 후 변경',
                    onTap: () => _showChangePasswordSheet(context),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.fingerprint,
                    title: '간편로그인 설정',
                    subtitle: '지문 · 간편비밀번호 · 패턴',
                    onTap: () => context.push('/mypage/quick-login'),
                  ),
                ],
              ),
            ),

            // ── 금융 ────────────────────────────────────────────
            _Section(
              title: '금융',
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.account_balance_outlined,
                    title: '내 계좌',
                    subtitle: '보유 계좌·잔액 조회',
                    onTap: () => context.push('/mypage/accounts'),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.bar_chart_outlined,
                    title: '소비 패턴',
                    subtitle: '지출 현황 등록/수정',
                    onTap: () => context.push('/spending/input'),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.smart_toy_outlined,
                    title: 'AI 카드 추천',
                    subtitle: '소비 패턴 기반 맞춤 추천',
                    onTap: () => context.go('/ai/chat'),
                  ),
                ],
              ),
            ),

            // ── 알림 ────────────────────────────────────────────
            _Section(
              title: '알림',
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.notifications_active_outlined,
                    title: '알림함',
                    subtitle: '받은 알림 확인',
                    onTap: () => context.push('/notifications'),
                  ),
                  const _TileDivider(),
                  _SwitchTile(
                    icon: Icons.notifications_outlined,
                    title: '푸시 알림',
                    value: _pushEnabled,
                    onChanged: _savePush,
                  ),
                  const _TileDivider(),
                  _SwitchTile(
                    icon: Icons.campaign_outlined,
                    title: '마케팅 알림',
                    value: _marketingEnabled,
                    onChanged: _saveMarketing,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 3),
    );
  }

  // ── 알림 설정 저장 ────────────────────────────────────────────────
  Future<void> _savePush(bool v) async {
    final prev = _pushEnabled;
    setState(() => _pushEnabled = v);
    try {
      await ref
          .read(mypageDatasourceProvider)
          .updateNotificationSettings(pushEnabled: v);
      if (v) {
        await PushService.instance.registerToken();
      } else {
        await PushService.instance.unregister();
      }
      ref.invalidate(myInfoProvider); // 캐시 갱신 → 재진입 시 값 유지
    } catch (_) {
      if (!mounted) return;
      setState(() => _pushEnabled = prev);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 저장에 실패했습니다.')),
      );
    }
  }

  Future<void> _saveMarketing(bool v) async {
    final prev = _marketingEnabled;
    setState(() => _marketingEnabled = v);
    try {
      await ref
          .read(mypageDatasourceProvider)
          .updateNotificationSettings(marketingAgree: v);
      ref.invalidate(myInfoProvider); // 캐시 갱신 → 재진입 시 값 유지
    } catch (_) {
      if (!mounted) return;
      setState(() => _marketingEnabled = prev);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('설정 저장에 실패했습니다.')),
      );
    }
  }

  // ── 바텀시트: 내 정보 수정 ────────────────────────────────────────
  void _showEditInfoSheet(BuildContext context, Map<String, dynamic> info) {
    final nameCtrl = TextEditingController(text: info['name'] as String? ?? '');
    final phoneCtrl =
    TextEditingController(text: info['phone'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // #5 시스템 내비게이션 바 가림 방지
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(hintText: '이름'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(hintText: '휴대폰 번호'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  final ds = ref.read(mypageDatasourceProvider);
                  try {
                    await ds.updateMyInfo({
                      'name': nameCtrl.text,
                      'phone': phoneCtrl.text,
                    });
                    ref.invalidate(myInfoProvider);
                    if (ctx.mounted) Navigator.pop(ctx);
                  } catch (_) {
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

  // ── 바텀시트: 비밀번호 변경 ──────────────────────────────────────
  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController(); // #7 새 비밀번호 확인
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true, // #5 시스템 내비게이션 바 가림 방지
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
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
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
            const SizedBox(height: 10),
            TextField(
              controller: confirmCtrl, // #7 확인 필드 (웹과 동일한 흐름)
              obscureText: true,
              decoration: const InputDecoration(hintText: '새 비밀번호 확인'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  // 클라이언트 1차 검증 (웹과 동일)
                  if (newCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('새 비밀번호와 확인이 일치하지 않습니다.')));
                    return;
                  }
                  if (newCtrl.text == currentCtrl.text) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('현재 비밀번호와 다른 비밀번호를 입력해 주세요.')));
                    return;
                  }
                  final ds = ref.read(mypageDatasourceProvider);
                  try {
                    // #7 서버 계약: currentPassword/newPassword/newPasswordConfirm
                    await ds.changePassword(
                        currentCtrl.text, newCtrl.text, confirmCtrl.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
                      );
                    }
                  } on DioException catch (e) {
                    final code = e.response?.data is Map
                        ? (e.response?.data as Map)['code']
                        : null;
                    final msg = switch (code) {
                      'U009' => '새 비밀번호와 확인이 일치하지 않습니다.',
                      'U003' => '현재 비밀번호가 올바르지 않습니다.',
                    // PASSWORD_RECENTLY_USED — 실제 코드값은 서버 ErrorCode 확인
                      'U011' => '최근 사용한 비밀번호는 다시 사용할 수 없습니다.',
                      _ => '변경에 실패했습니다.',
                    };
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx)
                          .showSnackBar(SnackBar(content: Text(msg)));
                    }
                  } catch (_) {
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
}

// ══════════════════════════════════════════════════════════════════
//  하위 위젯
// ══════════════════════════════════════════════════════════════════

/// 프로필 헤더 (teal 배경 + 이니셜 아바타)
class _ProfileHeader extends StatelessWidget {
  final bool loading;
  final String initial;
  final String name;
  final String maskedEmail;
  final String maskedPhone;

  const _ProfileHeader({
    required this.loading,
    required this.initial,
    required this.name,
    required this.maskedEmail,
    required this.maskedPhone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.teal900,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: loading
          ? const SizedBox(
        height: 64,
        child:
        Center(child: CircularProgressIndicator(color: Colors.white70)),
      )
          : Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '회원' : '$name 님',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                if (maskedEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(maskedEmail,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white60)),
                ],
                if (maskedPhone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(maskedPhone,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.white60)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 래퍼 — 라벨 + 흰 카드(둥근 모서리)로 그룹을 분리
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Text(
            title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal600,
                letterSpacing: 0.3),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

/// 메뉴 행 (아이콘 + 제목/부제 + 화살표)
class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!,
          style: const TextStyle(fontSize: 12, color: AppColors.gray400)),
      trailing:
      const Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
      onTap: onTap,
    );
  }
}

/// 토글 행
class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      value: value,
      activeThumbColor: AppColors.teal600,
      onChanged: onChanged,
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, indent: 16, endIndent: 16, color: AppColors.gray100);
}

/// 내 카드(보유/신청) 탭 카드 — 표시 전용
class _MyCardsCard extends StatelessWidget {
  final TabController tabController;
  final AsyncValue<Map<String, dynamic>> cardsAsync;
  const _MyCardsCard({required this.tabController, required this.cardsAsync});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          labelColor: AppColors.teal600,
          unselectedLabelColor: AppColors.gray400,
          indicatorColor: AppColors.teal600,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: '보유 카드'),
            Tab(text: '신청 현황'),
          ],
        ),
        SizedBox(
          height: 220,
          child: cardsAsync.when(
            loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Center(
                child: Text('불러오지 못했습니다.',
                    style: TextStyle(color: AppColors.gray400))),
            data: (data) {
              final owned = _asList(data['ownedCards']);
              final applied =
              _asList(data['applications'] ?? data['appliedCards']);
              return TabBarView(
                controller: tabController,
                children: [
                  _OwnedList(items: owned),
                  _AppliedList(items: applied),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static List<Map<String, dynamic>> _asList(Object? v) =>
      (v as List? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
}

class _OwnedList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _OwnedList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCards(
        icon: Icons.credit_card_off_outlined,
        message: '보유 카드가 없습니다.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: AppColors.gray100),
      itemBuilder: (_, i) {
        final c = items[i];
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _CardChip(),
          title: Text(
            c['cardName'] as String? ?? '카드',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          dense: true,
          // 표시 전용 — onTap 없음
        );
      },
    );
  }
}

class _AppliedList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _AppliedList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCards(
        icon: Icons.assignment_outlined,
        message: '신청 이력이 없습니다.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
      const Divider(height: 1, color: AppColors.gray100),
      itemBuilder: (_, i) {
        final c = items[i];
        final status = c['applicationStatus'] as String? ??
            c['statusCode'] as String? ??
            '';
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _CardChip(),
          title: Text(
            c['cardName'] as String? ?? '카드',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            _statusLabel(status),
            style: TextStyle(fontSize: 11, color: _statusColor(status)),
          ),
          dense: true,
        );
      },
    );
  }

  static String _statusLabel(String s) => switch (s) {
    'DRAFT' => '임시저장',
    'REQUESTED' => '신청접수',
    'REVIEWING' => '심사중',
    'SUBMITTED' => '심사중',
    'APPROVED' => '승인완료',
    'REJECTED' => '반려',
    'ISSUED' => '발급완료',
    _ => s,
  };

  static Color _statusColor(String s) => switch (s) {
    'APPROVED' || 'ISSUED' => AppColors.teal600,
    'REJECTED' => Colors.red,
    _ => AppColors.gray400,
  };
}

class _CardChip extends StatelessWidget {
  const _CardChip();
  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 26,
    decoration: BoxDecoration(
      color: AppColors.teal800,
      borderRadius: BorderRadius.circular(5),
    ),
    child: const Icon(Icons.credit_card, size: 14, color: Colors.white),
  );
}

class _EmptyCards extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCards({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: AppColors.gray400),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.gray400)),
        ],
      ),
    );
  }
}