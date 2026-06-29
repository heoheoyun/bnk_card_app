// 마이페이지 > 내 카드 > 카드 관리 화면.
//  - USER_CARDS 컬럼 기반으로 보유 카드를 직접 관리한다.
//  - 해외사용/비접촉 토글(ACTIVE 상태일 때만), 한도·별칭 변경(바텀시트),
//    일시정지/재개, 분실신고.
//  - 각 액션은 PATCH /api/users/me/cards/{userCardId} 후 provider invalidate.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../application/domain/entities/user_card.dart';
import '../providers/mypage_provider.dart';

class MyCardDetailPage extends ConsumerWidget {
  final int userCardId;
  const MyCardDetailPage({super.key, required this.userCardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(userCardProvider(userCardId));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '카드 관리', backPath: '/mypage'),
      body: cardAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (_, __) => const Center(
          child: Text('카드 정보를 불러오지 못했습니다.',
              style: TextStyle(color: AppColors.gray400)),
        ),
        data: (card) => _body(context, ref, card),
      ),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, UserCard card) {
    // EXPIRED / REISSUED / LOST 카드는 서버에서 변경을 차단하므로 컨트롤도 비활성화.
    final canManage = card.cardStatus == CardStatus.active ||
        card.cardStatus == CardStatus.stopped;
    final isActive = card.cardStatus == CardStatus.active;

    return ListView(
      children: [
        _CardHeader(card: card),

        if (!canManage)
          Container(
            width: double.infinity,
            color: AppColors.gray100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '${card.cardStatus.label} 상태의 카드는 설정을 변경할 수 없습니다.',
              style: const TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
          ),

        const SizedBox(height: 8),
        _sectionHeader('사용 설정'),
        SwitchListTile(
          secondary: const Icon(Icons.public, color: AppColors.primary),
          title: const Text('해외 사용'),
          subtitle: const Text('해외 가맹점·온라인 결제 허용'),
          value: card.overseasEnabledYn == 'Y',
          activeThumbColor: AppColors.teal600,
          onChanged: isActive
              ? (v) => _patch(context, ref,
                  {'overseasEnabledYn': v ? 'Y' : 'N'})
              : null,
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(Icons.contactless, color: AppColors.primary),
          title: const Text('비접촉 결제'),
          subtitle: const Text('터치 결제(컨택리스) 허용'),
          value: card.contactlessEnabledYn == 'Y',
          activeThumbColor: AppColors.teal600,
          onChanged: isActive
              ? (v) => _patch(context, ref,
                  {'contactlessEnabledYn': v ? 'Y' : 'N'})
              : null,
        ),
        const Divider(height: 1),

        const SizedBox(height: 8),
        _sectionHeader('한도 및 정보'),
        ListTile(
          leading: const Icon(Icons.tune, color: AppColors.primary),
          title: const Text('이용 한도 변경'),
          subtitle: Text(
            '일일 ${_won(card.dailyLimitAmount)}'
            '${card.monthlyLimitAmount != null ? ' · 월 ${_won(card.monthlyLimitAmount!)}' : ''}',
            style: const TextStyle(fontSize: 12, color: AppColors.gray400),
          ),
          trailing: const Icon(Icons.chevron_right,
              size: 18, color: AppColors.gray400),
          enabled: canManage,
          onTap: canManage ? () => _showLimitSheet(context, ref, card) : null,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
          title: const Text('카드 별칭'),
          subtitle: Text(
            card.cardNickname?.isNotEmpty == true ? card.cardNickname! : '미설정',
            style: const TextStyle(fontSize: 12, color: AppColors.gray400),
          ),
          trailing: const Icon(Icons.chevron_right,
              size: 18, color: AppColors.gray400),
          enabled: canManage,
          onTap: canManage
              ? () => _showNicknameSheet(context, ref, card)
              : null,
        ),
        const Divider(height: 1),

        const SizedBox(height: 8),
        _sectionHeader('카드 상태'),
        ListTile(
          leading: Icon(isActive ? Icons.pause_circle_outline : Icons.play_circle_outline,
              color: AppColors.primary),
          title: Text(isActive ? '카드 일시정지' : '카드 사용 재개'),
          subtitle: Text(
            isActive ? '결제를 일시적으로 막습니다.' : '정지된 카드를 다시 사용합니다.',
            style: const TextStyle(fontSize: 12, color: AppColors.gray400),
          ),
          enabled: canManage,
          onTap: canManage
              ? () => _patch(context, ref,
                  {'cardStatus': isActive ? 'STOPPED' : 'ACTIVE'})
              : null,
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.report_gmailerrorred_outlined, color: Colors.red),
          title: const Text('분실 신고', style: TextStyle(color: Colors.red)),
          subtitle: const Text('신고 시 카드 사용이 영구 정지됩니다.',
              style: TextStyle(fontSize: 12, color: AppColors.gray400)),
          enabled: canManage,
          onTap: canManage ? () => _confirmLost(context, ref) : null,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── PATCH 공통 처리 ───────────────────────────────────────────────
  Future<void> _patch(
      BuildContext context, WidgetRef ref, Map<String, dynamic> patch) async {
    try {
      await ref.read(mypageDatasourceProvider).patchUserCard(userCardId, patch);
      ref.invalidate(userCardProvider(userCardId));
      ref.invalidate(myCardsProvider); // 목록의 별칭/상태도 갱신
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('변경에 실패했습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  // ── 바텀시트: 한도 변경 ───────────────────────────────────────────
  void _showLimitSheet(BuildContext context, WidgetRef ref, UserCard card) {
    final dailyCtrl =
        TextEditingController(text: card.dailyLimitAmount.toString());
    final monthlyCtrl = TextEditingController(
        text: card.monthlyLimitAmount?.toString() ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
            const Text('이용 한도 변경',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: dailyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: '일일 한도(원)', hintText: '예: 1000000'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: monthlyCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                  labelText: '월 한도(원)', hintText: '신용카드만 해당'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  final daily = int.tryParse(dailyCtrl.text.trim());
                  final monthly = monthlyCtrl.text.trim().isEmpty
                      ? null
                      : int.tryParse(monthlyCtrl.text.trim());
                  if (daily == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                        content: Text('일일 한도를 올바르게 입력해주세요.')));
                    return;
                  }
                  Navigator.pop(ctx);
                  await _patch(context, ref, {
                    'dailyLimitAmount': daily,
                    if (monthly != null) 'monthlyLimitAmount': monthly,
                  });
                },
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 바텀시트: 별칭 변경 ───────────────────────────────────────────
  void _showNicknameSheet(BuildContext context, WidgetRef ref, UserCard card) {
    final nickCtrl = TextEditingController(text: card.cardNickname ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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
            const Text('카드 별칭',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            TextField(
              controller: nickCtrl,
              maxLength: 50,
              decoration: const InputDecoration(hintText: '예: 생활비 카드'),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal600,
                    foregroundColor: Colors.white),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await _patch(context, ref,
                      {'cardNickname': nickCtrl.text.trim()});
                },
                child: const Text('저장하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 분실신고 확인 ─────────────────────────────────────────────────
  Future<void> _confirmLost(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('분실 신고'),
        content: const Text('분실 신고 시 이 카드는 영구적으로 사용 정지됩니다.\n계속하시겠어요?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('신고', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await _patch(context, ref, {'cardStatus': 'LOST'});
    }
  }

  // ── 헬퍼 ──────────────────────────────────────────────────────────
  static String _won(int amount) {
    final s = amount.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()}원';
  }

  static Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(text,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray400)),
      );
}

/// 카드 헤더 — 마스킹 번호 + 상태 뱃지
class _CardHeader extends StatelessWidget {
  final UserCard card;
  const _CardHeader({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.teal900,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.credit_card, color: Colors.white70, size: 28),
              _StatusBadge(status: card.cardStatus),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            card.cardNickname?.isNotEmpty == true
                ? card.cardNickname!
                : (card.isCreditCard ? '신용카드' : '체크카드'),
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            card.maskedCardNumber,
            style: const TextStyle(
                color: Colors.white70, fontSize: 14, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final CardStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      CardStatus.active => Colors.greenAccent,
      CardStatus.stopped => Colors.orangeAccent,
      _ => Colors.redAccent,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
