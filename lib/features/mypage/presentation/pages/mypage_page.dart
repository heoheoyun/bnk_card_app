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
import '../../../../shared/widgets/home_back_scope.dart';
import '../providers/mypage_provider.dart';
import '../widgets/my_cards_section.dart';



class MyPagePage extends ConsumerStatefulWidget {
  const MyPagePage({super.key});

  @override
  ConsumerState<MyPagePage> createState() => _MyPagePageState();
}

class _MyPagePageState extends ConsumerState<MyPagePage> {
  bool _pushEnabled = true;
  bool _marketingEnabled = false;
  bool _seeded = false; // 서버값 1회 동기화

  // ── 빌드 ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final myInfoAsync = ref.watch(myInfoProvider);

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

    return HomeBackScope(
      child: Scaffold(
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
              child: const MyCardsSection(),
            ),

            // ── 계정 ────────────────────────────────────────────
            _Section(
              title: '계정',
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.person_outline,
                    title: '내 정보 수정',
                    subtitle: '이름·전화번호·직업·소득 변경',
                    onTap: () => _showEditInfoDialog(context, info),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.home_outlined,
                    title: '주소 변경',
                    subtitle: '본인인증 후 주소 변경',
                    onTap: () => context.push('/mypage/address-verify'),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.lock_outline,
                    title: '비밀번호 변경',
                    subtitle: '현재 비밀번호 확인 후 변경',
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.fingerprint,
                    title: '간편로그인 설정',
                    subtitle: '지문 · 간편비밀번호 · 패턴',
                    onTap: () => context.push('/mypage/quick-login'),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.devices_outlined,
                    title: '신뢰 기기 관리',
                    subtitle: '등록된 기기 확인·이름·삭제',
                    onTap: () => context.push('/mypage/trusted-devices'),
                  ),
                  const _TileDivider(),
                  _MenuTile(
                    icon: Icons.local_shipping_outlined,
                    title: '배송지 관리',
                    subtitle: '카드 배송지 주소 등록·별칭·기본 설정',
                    onTap: () => context.push('/mypage/addresses'),
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
      ),
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

  // ── 다이얼로그 공용 셸: 화면 중앙 + 키보드 위로 자동 이동 + 내부 스크롤 ──
  //   (바텀시트는 키보드가 올라오면 하단이 잘리는 문제가 있어 중앙 다이얼로그로 전환)
  Widget _dialogShell(BuildContext ctx,
      {required String title, required List<Widget> children}) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 18),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6, top: 2),
        child: Text(t,
            style: const TextStyle(
                fontSize: 12,
                color: AppColors.gray600,
                fontWeight: FontWeight.w500)),
      );

  InputDecoration _dialogInput(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
        isDense: true,
        filled: true,
        fillColor: AppColors.gray100,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.teal600, width: 1.2),
        ),
      );

  Widget _dialogActions(BuildContext ctx,
          {required String submitLabel, required VoidCallback onSubmit}) =>
      Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.gray600,
                  side: const BorderSide(color: AppColors.gray200),
                  padding: const EdgeInsets.symmetric(vertical: 13)),
              child: const Text('취소'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13)),
              child: Text(submitLabel),
            ),
          ),
        ],
      );

  // ── 다이얼로그: 내 정보 수정 (이름·휴대폰·직업·소득 + 본인확인) ────────
  void _showEditInfoDialog(BuildContext context, Map<String, dynamic> info) {
    final nameCtrl = TextEditingController(text: info['name'] as String? ?? '');
    final phoneCtrl =
        TextEditingController(text: info['phone'] as String? ?? '');
    final pwCtrl = TextEditingController();
    const jobs = {'EMPLOYED', 'SELF_EMPLOYED', 'STUDENT', 'UNEMPLOYED', 'OTHER'};
    const incomes = {'LV1', 'LV2', 'LV3', 'LV4'};
    // 드롭다운 목록에 없는 값이 들어오면 DropdownButtonFormField 가 assert 로 죽으므로 클램프.
    String? job = jobs.contains(info['job']) ? info['job'] as String : null;
    String? income =
        incomes.contains(info['incomeLevelCode']) ? info['incomeLevelCode'] as String : null;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => _dialogShell(
          ctx,
          title: '내 정보 수정',
          children: [
            _fieldLabel('이름'),
            TextField(controller: nameCtrl, decoration: _dialogInput('이름 입력')),
            const SizedBox(height: 14),
            _fieldLabel('휴대폰 번호'),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: _dialogInput('01012345678'),
            ),
            const SizedBox(height: 14),
            _fieldLabel('직업'),
            DropdownButtonFormField<String>(
              initialValue: job,
              isExpanded: true,
              decoration: _dialogInput('선택 안함'),
              items: const [
                DropdownMenuItem(value: 'EMPLOYED', child: Text('직장인')),
                DropdownMenuItem(value: 'SELF_EMPLOYED', child: Text('자영업')),
                DropdownMenuItem(value: 'STUDENT', child: Text('학생')),
                DropdownMenuItem(value: 'UNEMPLOYED', child: Text('무직')),
                DropdownMenuItem(value: 'OTHER', child: Text('기타')),
              ],
              onChanged: (v) => setLocal(() => job = v),
            ),
            const SizedBox(height: 14),
            _fieldLabel('소득 등급'),
            DropdownButtonFormField<String>(
              initialValue: income,
              isExpanded: true,
              decoration: _dialogInput('선택 안함'),
              items: const [
                DropdownMenuItem(value: 'LV1', child: Text('LV1 · 연 3천만 원 미만')),
                DropdownMenuItem(value: 'LV2', child: Text('LV2 · 연 3천~5천만 원')),
                DropdownMenuItem(value: 'LV3', child: Text('LV3 · 연 5천만~1억 원')),
                DropdownMenuItem(value: 'LV4', child: Text('LV4 · 연 1억 원 이상')),
              ],
              onChanged: (v) => setLocal(() => income = v),
            ),
            const SizedBox(height: 14),
            _fieldLabel('현재 비밀번호'),
            TextField(
              controller: pwCtrl,
              obscureText: true,
              decoration: _dialogInput('본인확인을 위해 입력'),
            ),
            const SizedBox(height: 6),
            const Text('정보 변경 시 본인확인을 위해 현재 비밀번호가 필요합니다.',
                style: TextStyle(fontSize: 11, color: AppColors.gray400)),
            const SizedBox(height: 20),
            _dialogActions(
              ctx,
              submitLabel: '저장하기',
              onSubmit: () async {
                if (pwCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                      content: Text('현재 비밀번호를 입력해 주세요.')));
                  return;
                }
                final ds = ref.read(mypageDatasourceProvider);
                try {
                  await ds.updateMyInfo({
                    if (nameCtrl.text.trim().isNotEmpty)
                      'name': nameCtrl.text.trim(),
                    if (phoneCtrl.text.trim().isNotEmpty)
                      'phone': phoneCtrl.text.trim(),
                    if (job != null) 'job': job,
                    if (income != null) 'incomeLevelCode': income,
                    'currentPassword': pwCtrl.text,
                  });
                  ref.invalidate(myInfoProvider);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('정보가 수정되었습니다.')));
                  }
                } on DioException catch (e) {
                  final code = e.response?.data is Map
                      ? (e.response?.data as Map)['code']
                      : null;
                  final msg = switch (code) {
                    'U003' => '현재 비밀번호가 올바르지 않습니다.',
                    'C001' => '입력값을 확인해 주세요.',
                    'U010' => '이미 사용 중인 휴대폰 번호입니다.',
                    _ => '수정에 실패했습니다.',
                  };
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('수정에 실패했습니다.')));
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── 다이얼로그: 비밀번호 변경 ────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => _dialogShell(
          ctx,
          title: '비밀번호 변경',
          children: [
            _fieldLabel('현재 비밀번호'),
            TextField(
              controller: currentCtrl,
              obscureText: obscure,
              decoration: _dialogInput('현재 비밀번호').copyWith(
                suffixIcon: IconButton(
                  icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 18,
                      color: AppColors.gray400),
                  onPressed: () => setLocal(() => obscure = !obscure),
                ),
              ),
            ),
            const SizedBox(height: 14),
            _fieldLabel('새 비밀번호'),
            TextField(
              controller: newCtrl,
              obscureText: obscure,
              decoration: _dialogInput('영문·숫자·특수문자 조합 8자 이상'),
            ),
            const SizedBox(height: 14),
            _fieldLabel('새 비밀번호 확인'),
            TextField(
              controller: confirmCtrl,
              obscureText: obscure,
              decoration: _dialogInput('새 비밀번호 다시 입력'),
            ),
            const SizedBox(height: 20),
            _dialogActions(
              ctx,
              submitLabel: '변경하기',
              onSubmit: () async {
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
                  await ds.changePassword(
                      currentCtrl.text, newCtrl.text, confirmCtrl.text);
                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('비밀번호가 변경되었습니다.')));
                  }
                } on DioException catch (e) {
                  final code = e.response?.data is Map
                      ? (e.response?.data as Map)['code']
                      : null;
                  final msg = switch (code) {
                    'U009' => '새 비밀번호와 확인이 일치하지 않습니다.',
                    'U003' => '현재 비밀번호가 올바르지 않습니다.',
                    'U011' => '최근 사용한 비밀번호는 다시 사용할 수 없습니다.',
                    _ => '변경에 실패했습니다.',
                  };
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx)
                        .showSnackBar(SnackBar(content: Text(msg)));
                  }
                } catch (_) {
                  if (ctx.mounted) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('변경에 실패했습니다.')));
                  }
                }
              },
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
