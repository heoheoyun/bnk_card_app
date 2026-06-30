import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../domain/entities/credit_application.dart';
import '../../providers/credit_application_provider.dart';

class CreditResultPage extends ConsumerStatefulWidget {
  final int cardId;
  const CreditResultPage({super.key, required this.cardId});

  @override
  ConsumerState<CreditResultPage> createState() => _CreditResultPageState();
}

class _CreditResultPageState extends ConsumerState<CreditResultPage> {
  ApplicationStatus?  _status;
  int?                _approvedLimit;
  String?             _rejectionReason;
  CreditApplication?  _app;
  bool                _loading = true;
  bool                _invalidAccess = false;
  String?             _fetchError;

  @override
  void initState() {
    super.initState();
    _fetchResult();
  }

  Future<void> _fetchResult() async {
    final creditAppId = ref.read(creditApplicationProvider).creditAppId;
    if (creditAppId == null) {
      setState(() { _loading = false; _invalidAccess = true; });
      return;
    }
    try {
      final app = await ref
          .read(creditApplicationRepositoryProvider)
          .getApplication(creditAppId);
      if (mounted) {
        setState(() {
          _app             = app;
          _status          = app.applicationStatus;
          _approvedLimit   = app.approvedLimit;
          _rejectionReason = app.rejectionReason;
          _loading         = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _fetchError = e.toString(); });
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
    if (_invalidAccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            const Text('잘못된 접근입니다', style: TextStyle(fontSize: 16, color: AppColors.gray600)),
            const SizedBox(height: 24),
            TextButton(onPressed: () => context.go('/'), child: const Text('홈으로')),
          ],
        ),
      );
    }
    if (_fetchError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.gray400),
            const SizedBox(height: 16),
            const Text('결과를 불러오지 못했습니다', style: TextStyle(fontSize: 16, color: AppColors.gray600)),
            const SizedBox(height: 8),
            TextButton(onPressed: _fetchResult, child: const Text('다시 시도')),
            TextButton(onPressed: () => context.go('/mypage'), child: const Text('마이페이지로')),
          ],
        ),
      );
    }
    return switch (_status) {
      ApplicationStatus.issued || ApplicationStatus.approved => _IssuedView(
          cardId:        widget.cardId,
          approvedLimit: _approvedLimit,
        ),
      ApplicationStatus.reviewing => _app?.limitCheckResult == 'MANUAL_REQUIRED'
          ? _ReviewingView(
              creditAppId: ref.read(creditApplicationProvider).creditAppId ?? 0,
            )
          : const _AdminReviewingView(),
      ApplicationStatus.rejected => _RejectedView(
          reason: _rejectionReason,
        ),
      ApplicationStatus.screeningFailed => _ScreeningFailedView(
          creditAppId: ref.read(creditApplicationProvider).creditAppId ?? 0,
          onRetry: _retryScreening,
        ),
      _ => _PendingView(cardId: widget.cardId),
    };
  }

  Future<void> _retryScreening() async {
    final creditAppId = ref.read(creditApplicationProvider).creditAppId;
    if (creditAppId == null) return;
    setState(() { _loading = true; _fetchError = null; });
    try {
      await ref.read(creditApplicationRepositoryProvider).retryScreening(creditAppId);
      await _fetchResult();
    } catch (e) {
      if (mounted) setState(() { _loading = false; _fetchError = e.toString(); });
    }
  }
}

// ── 발급 완료 ──────────────────────────────────────────────────────
class _IssuedView extends StatelessWidget {
  final int  cardId;
  final int? approvedLimit;
  const _IssuedView({required this.cardId, this.approvedLimit});

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
                Text('승인 한도: ${approvedLimit != null ? '${(approvedLimit! / 10000).toInt()}만원' : '-'}',
                    style: const TextStyle(fontSize: 15, color: AppColors.teal600, fontWeight: FontWeight.w600)),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray100, borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(children: [
                    _InfoRow(label: '카드 상태', value: '발급 완료'),
                    SizedBox(height: 8),
                    _InfoRow(label: '확인', value: '마이페이지 > 보유 카드'),
                  ]),
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

// ── 추가심사 중 ────────────────────────────────────────────────────
class _ReviewingView extends StatelessWidget {
  final int creditAppId;
  const _ReviewingView({required this.creditAppId});

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
                    color: Color(0xFFFFF8E1), shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.description_outlined, color: Color(0xFFF59E0B), size: 44),
                ),
                const SizedBox(height: 24),
                const Text('추가 서류 제출이 필요합니다',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '심사를 위해 추가 서류 제출이 필요합니다.\n아래 버튼을 눌러 서류를 제출해 주세요.',
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
                BnkButton(
                  label: '서류 제출하기',
                  onPressed: () =>
                      context.go('/application/credit/$creditAppId/documents'),
                ),
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
                  child: const Column(children: [
                    _InfoRow(label: '문의', value: '1588-6200'),
                  ]),
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
                BnkButton(label: '홈으로', onPressed: () => context.go('/')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── 심사 오류 (SCREENING_FAILED) ──────────────────────────────────
class _ScreeningFailedView extends StatelessWidget {
  final int creditAppId;
  final VoidCallback onRetry;
  const _ScreeningFailedView({required this.creditAppId, required this.onRetry});

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

// ── 심사 대기 (REQUESTED/SUBMITTED) ───────────────────────────────
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
                Text('심사 결과는 영업일 기준 3~5일 이내에\n마이페이지에서 확인하실 수 있습니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.6)),
                const SizedBox(height: 32),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.gray100, borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(children: [
                    _InfoRow(label: '심사 기간', value: '영업일 3~5일'),
                    SizedBox(height: 8),
                    _InfoRow(label: '결과 확인', value: '마이페이지 > 신청 내역'),
                    SizedBox(height: 8),
                    _InfoRow(label: '문의', value: '1588-6200'),
                  ]),
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

// ── 심사 대기 (서류 없이 관리자 검토 중) ─────────────────────────────
class _AdminReviewingView extends StatelessWidget {
  const _AdminReviewingView();

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
                    color: Color(0xFFFFF8E1), shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_top_outlined, color: Color(0xFFF59E0B), size: 44),
                ),
                const SizedBox(height: 24),
                const Text('추가 심사가 진행 중입니다',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppColors.gray800)),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    '카드 신청에 대한 추가 심사가 진행 중입니다.\n결과는 영업일 기준 3~5일 이내 알림으로 안내드립니다.',
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
                BnkButton(label: '마이페이지로', onPressed: () => context.go('/mypage')),
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
