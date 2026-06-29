import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../domain/entities/check_application.dart';
import '../../../domain/entities/credit_application.dart' show ApplicationStatus;
import '../../providers/check_application_provider.dart';

class CheckResultPage extends ConsumerStatefulWidget {
  final int cardId;
  const CheckResultPage({super.key, required this.cardId});

  @override
  ConsumerState<CheckResultPage> createState() => _CheckResultPageState();
}

class _CheckResultPageState extends ConsumerState<CheckResultPage> {
  ApplicationStatus? _status;
  String?            _rejectionReason;
  bool               _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    final checkAppId = ref.read(checkApplicationProvider).checkAppId;
    if (checkAppId == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final app = await ref
          .read(checkApplicationRepositoryProvider)
          .getApplication(checkAppId);
      if (mounted) {
        setState(() {
          _status          = app.applicationStatus;
          _rejectionReason = app.rejectionReason;
          _loading         = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _retryScreening() async {
    final checkAppId = ref.read(checkApplicationProvider).checkAppId;
    if (checkAppId == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(checkApplicationRepositoryProvider).retryScreening(checkAppId);
      await _fetchResult();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const BnkAppBar(title: '카드 신청'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return switch (_status) {
      ApplicationStatus.issued || ApplicationStatus.approved => _IssuedView(
          cardId: widget.cardId,
        ),
      ApplicationStatus.rejected => _RejectedView(
          reason: _rejectionReason,
        ),
      ApplicationStatus.screeningFailed => _ScreeningFailedView(
          onRetry: _retryScreening,
        ),
      _ => _PendingView(cardId: widget.cardId),
    };
  }
}

// ── 발급 완료 ──────────────────────────────────────────────────────
class _IssuedView extends StatelessWidget {
  final int cardId;
  const _IssuedView({required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.teal50, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.credit_card, color: AppColors.teal600, size: 44),
                ),
                const SizedBox(height: 24),
                const Text('카드 발급이 완료되었습니다',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                const SizedBox(height: 12),
                const Text('마이페이지에서 발급된 카드를 확인해 보세요.',
                    style: TextStyle(fontSize: 14, color: AppColors.gray600)),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                BnkButton(label: '카드 상세 보기', onPressed: () => context.go('/cards/$cardId')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('홈으로', style: TextStyle(fontSize: 14, color: AppColors.gray600)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 거절 ───────────────────────────────────────────────────────────
class _RejectedView extends StatelessWidget {
  final String? reason;
  const _RejectedView({this.reason});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEE2E2), shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626), size: 44),
                ),
                const SizedBox(height: 24),
                const Text('신청이 반려되었습니다',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                if (reason != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(reason!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.6)),
                  ),
                ],
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray100, borderRadius: BorderRadius.circular(12),
                  ),
                  child: const _InfoRow(label: '문의', value: '1588-6200'),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: BnkButton(label: '홈으로', onPressed: () => context.go('/')),
          ),
        ),
      ],
    );
  }
}

// ── 심사 오류 (SCREENING_FAILED) ──────────────────────────────────
class _ScreeningFailedView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ScreeningFailedView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF3CD), shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_off_outlined, color: Color(0xFFF59E0B), size: 44),
                ),
                const SizedBox(height: 24),
                const Text('심사 요청에 실패했습니다',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '일시적인 네트워크 오류로 심사 요청에 실패했습니다.\n잠시 후 다시 시도해 주세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.6),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                BnkButton(label: '심사 재시도', onPressed: onRetry),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/mypage'),
                  child: const Text('나중에 하기', style: TextStyle(fontSize: 14, color: AppColors.gray600)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 심사 대기 (REQUESTED) ──────────────────────────────────────────
class _PendingView extends StatelessWidget {
  final int cardId;
  const _PendingView({required this.cardId});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(
                    color: AppColors.teal50, shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_outline, color: AppColors.teal600, size: 48),
                ),
                const SizedBox(height: 24),
                const Text('신청이 완료되었습니다',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                const SizedBox(height: 12),
                const Text(
                  '심사 결과는 영업일 기준 1~3일 이내에\n마이페이지에서 확인하실 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.6),
                ),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray100, borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      _InfoRow(label: '심사 기간', value: '영업일 1~3일'),
                      SizedBox(height: 8),
                      _InfoRow(label: '결과 확인', value: '마이페이지 > 신청 내역'),
                      SizedBox(height: 8),
                      _InfoRow(label: '문의',      value: '1588-6200'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                BnkButton(label: '카드 상세 보기', onPressed: () => context.go('/cards/$cardId')),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('홈으로', style: TextStyle(fontSize: 14, color: AppColors.gray600)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.gray600)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.gray800)),
      ],
    );
  }
}
