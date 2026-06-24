import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../providers/mypage_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/services/biometric_service.dart';
import '../../data/datasource/mypage_remote_datasource.dart';
import '../../../../core/push/push_service.dart';

class MyPagePage extends ConsumerStatefulWidget {
  const MyPagePage({super.key});

  @override
  ConsumerState<MyPagePage> createState() => _MyPagePageState();
}

class _MyPagePageState extends ConsumerState<MyPagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _biometricEnabled = false;
  bool _pushEnabled = true;
  bool _marketingEnabled = false;
  bool _seeded = false;                       // 서버값 1회 동기화 플래그
  final _userDs = MypageRemoteDatasource();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBiometricSetting();
  }

  /// 생체인증은 로컬 저장값 사용 (서버 미연동)
  Future<void> _loadBiometricSetting() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _biometricEnabled = prefs.getBool(StorageKeys.biometricEnabled) ?? false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final myInfoAsync  = ref.watch(myInfoProvider);
    final myCardsAsync = ref.watch(myCardsProvider);

    final info = myInfoAsync.valueOrNull ?? {};
    if (!_seeded && myInfoAsync.hasValue) {
      _pushEnabled      = (info['pushEnabled']    as String? ?? 'Y') == 'Y';
      _marketingEnabled = (info['marketingAgree'] as String? ?? 'N') == 'Y';
      _seeded = true;
    }
    final name        = info['name']        as String? ?? '';
    final maskedEmail = info['maskedEmail'] as String? ?? info['email'] as String? ?? '';
    final maskedPhone = info['maskedPhone'] as String? ?? '';
    final creditScore = info['creditScore'] as int?;
    final initial     = name.isNotEmpty ? name.substring(0, 1) : '?';

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
                height: 80,
                child: Center(
                    child: CircularProgressIndicator(color: Colors.white70)),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (_) => Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56, height: 56,
                        decoration: const BoxDecoration(
                          color: Colors.white24,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(initial,
                              style: const TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('$name 님',
                                style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(maskedEmail,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white60)),
                            if (maskedPhone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(maskedPhone,
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.white60)),
                            ],
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _showEditInfoSheet(context, info),
                        icon: const Icon(Icons.chevron_right,
                            color: Colors.white60),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // 신용점수 버튼
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.credit_score,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            creditScore != null
                                ? '신용점수 $creditScore점'
                                : '신용점수 확인하기',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── 개인정보 관리 ────────────────────────────────────
          _sectionTitle('개인정보 관리'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.person_outline,
                  title: '내 정보 수정',
                  subtitle: '이름·전화번호·주소 변경',
                  onTap: () => _showEditInfoSheet(context, info),
                ),
                _menuTile(
                  icon: Icons.lock_outline,
                  title: '비밀번호 변경',
                  subtitle: '현재 비밀번호 확인 후 변경',
                  onTap: () => _showChangePasswordSheet(context),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 인증 수단 관리
          ListTile(
            leading: const Icon(Icons.lock_outline, color: AppColors.primary),
            title: const Text('간편로그인 설정'),
            subtitle: const Text('지문 · 간편비밀번호 · 패턴'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/mypage/quick-login'),
          ),

          // ── 금융 정보 ────────────────────────────────────────
          _sectionTitle('금융 정보'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.bar_chart_outlined,
                  title: '소비 패턴',
                  subtitle: '지출 현황 등록/수정',
                  onTap: () => context.push('/spending/input'),
                ),
                _menuTile(
                  icon: Icons.credit_score_outlined,
                  title: '신용점수',
                  subtitle: creditScore != null ? '$creditScore점' : '점수 조회',
                  onTap: () {},
                ),
                _menuTile(
                  icon: Icons.account_balance_outlined,
                  title: '소득 정보',
                  subtitle: '직업·소득 등급',
                  onTap: () => _showEditInfoSheet(context, info),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── 보안 설정 ────────────────────────────────────────
          _sectionTitle('보안 설정'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _menuTile(
                  icon: Icons.fingerprint,
                  title: '생체인증 설정',
                  onTap: () {},
                  trailing: Switch(
                    value: _biometricEnabled,
                    activeThumbColor: AppColors.teal600,
                    onChanged: (v) async {
                      if (v) {
                        final success = await BiometricService.authenticate(
                          reason: '생체인증을 등록합니다',
                        );
                        if (!success) return;
                      }
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setBool(StorageKeys.biometricEnabled, v);
                      setState(() => _biometricEnabled = v);
                    },
                  ),
                ),
                _menuTile(
                  icon: Icons.notifications_outlined,
                  title: '푸시 알림',
                  onTap: () {},
                  trailing: Switch(
                    value: _pushEnabled,
                    activeThumbColor: AppColors.teal600,
                    onChanged: (v) => _savePush(v),
                  ),
                ),
                _menuTile(
                  icon: Icons.campaign_outlined,
                  title: '마케팅 알림',
                  onTap: () {},
                  trailing: Switch(
                    value: _marketingEnabled,
                    activeThumbColor: AppColors.teal600,
                    onChanged: (v) => _saveMarketing(v),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── 내 카드 ──────────────────────────────────────────
          _sectionTitle('내 카드'),
          Container(
            color: Colors.white,
            child: Column(
              children: [
                TabBar(
                  controller: _tabController,
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
                  height: 200,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // 보유 카드 탭
                      myCardsAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        error: (_, __) => const Center(
                            child: Text('불러오지 못했습니다.',
                                style: TextStyle(color: AppColors.gray400))),
                        data: (data) {
                          final owned = (data['ownedCards'] as List? ?? [])
                              .map((e) =>
                          Map<String, dynamic>.from(e as Map))
                              .toList();
                          if (owned.isEmpty) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.credit_card_off_outlined,
                                      size: 32, color: AppColors.gray400),
                                  const SizedBox(height: 8),
                                  const Text('보유 카드가 없습니다.',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: AppColors.gray400)),
                                  const SizedBox(height: 8),
                                  TextButton(
                                    onPressed: () => context.go('/search'),
                                    child: const Text('카드 신청하러 가기',
                                        style: TextStyle(
                                            color: AppColors.teal600,
                                            fontSize: 12)),
                                  ),
                                ],
                              ),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: owned.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: AppColors.gray100),
                            itemBuilder: (_, i) {
                              final c = owned[i];
                              return ListTile(
                                leading: Container(
                                  width: 40, height: 26,
                                  decoration: BoxDecoration(
                                    color: AppColors.teal800,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(Icons.credit_card,
                                      size: 14, color: Colors.white),
                                ),
                                title: Text(
                                    c['cardName'] as String? ?? '카드',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                dense: true,
                                trailing: const Icon(Icons.chevron_right,
                                    size: 16, color: AppColors.gray400),
                                onTap: () {},
                              );
                            },
                          );
                        },
                      ),

                      // 신청 현황 탭
                      myCardsAsync.when(
                        loading: () => const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        error: (_, __) => const Center(
                            child: Text('불러오지 못했습니다.',
                                style: TextStyle(color: AppColors.gray400))),
                        data: (data) {
                          final apps =
                          (data['applications'] as List? ?? [])
                              .map((e) =>
                          Map<String, dynamic>.from(e as Map))
                              .toList();
                          if (apps.isEmpty) {
                            return const Center(
                              child: Text('신청 내역이 없습니다.',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.gray400)),
                            );
                          }
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            itemCount: apps.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: AppColors.gray100),
                            itemBuilder: (_, i) {
                              final a = apps[i];
                              final status =
                                  a['applicationStatus'] as String? ?? '';
                              return ListTile(
                                leading: Container(
                                  width: 40, height: 26,
                                  decoration: BoxDecoration(
                                    color: AppColors.gray200,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(Icons.credit_card,
                                      size: 14, color: AppColors.gray600),
                                ),
                                title: Text(
                                    a['cardName'] as String? ?? '카드',
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500)),
                                subtitle: Text(
                                    _statusLabel(status),
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: _statusColor(status))),
                                dense: true,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── AI 카드 추천 ─────────────────────────────────────
          Container(
            color: Colors.white,
            child: _menuTile(
              icon: Icons.smart_toy_outlined,
              title: 'AI 카드 추천',
              subtitle: '소비 패턴 기반 맞춤 추천',
              onTap: () => context.go('/ai/chat'),
            ),
          ),

          const SizedBox(height: 90),
        ],
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 3),
    );
  }

  String _statusLabel(String status) => switch (status) {
    'DRAFT'     => '임시저장',
    'SUBMITTED' => '심사중',
    'APPROVED'  => '승인완료',
    'REJECTED'  => '반려',
    'ISSUED'    => '발급완료',
    _           => status,
  };

  Color _statusColor(String status) => switch (status) {
    'APPROVED' || 'ISSUED' => AppColors.teal600,
    'REJECTED'             => Colors.red,
    _                      => AppColors.gray400,
  };

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
    child: Text(title,
        style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.teal600,
            letterSpacing: 0.3)),
  );

  Widget _menuTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: const BoxDecoration(
          border:
          Border(top: BorderSide(color: AppColors.gray100, width: 0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 19, color: AppColors.gray600),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.gray800)),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: AppColors.gray400)),
                  ],
                ],
              ),
            ),
            trailing ??
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl     = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('비밀번호 변경',
                style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            TextField(
                controller: currentCtrl,
                obscureText: true,
                decoration: const InputDecoration(hintText: '현재 비밀번호')),
            const SizedBox(height: 10),
            TextField(
                controller: newCtrl,
                obscureText: true,
                decoration:
                const InputDecoration(hintText: '새 비밀번호')),
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
                    await ds.changePassword(
                        currentCtrl.text, newCtrl.text);
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('비밀번호가 변경되었습니다.')),
                      );
                    }
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
      BuildContext context, Map<String, dynamic> info) {
    final nameCtrl  = TextEditingController(text: info['name'] as String? ?? '');
    final phoneCtrl = TextEditingController(text: info['phone'] as String? ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('내 정보 수정',
                style:
                TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(hintText: '이름')),
            const SizedBox(height: 10),
            TextField(
                controller: phoneCtrl,
                decoration:
                const InputDecoration(hintText: '휴대폰 번호')),
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

  Future<void> _savePush(bool v) async {
    final prev = _pushEnabled;
    setState(() => _pushEnabled = v);
    try {
      await _userDs.updateNotificationSettings(pushEnabled: v);
      // 디바이스 토큰 동기화: ON이면 등록, OFF면 해제
      if (v) {
        await PushService.instance.registerToken();
      } else {
        await PushService.instance.unregister();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _pushEnabled = prev);          // 실패 롤백
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 저장에 실패했습니다.')));
    }
  }

  Future<void> _saveMarketing(bool v) async {
    final prev = _marketingEnabled;
    setState(() => _marketingEnabled = v);
    try {
      await _userDs.updateNotificationSettings(marketingAgree: v);
    } catch (_) {
      if (!mounted) return;
      setState(() => _marketingEnabled = prev);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('설정 저장에 실패했습니다.')));
    }
  }
}