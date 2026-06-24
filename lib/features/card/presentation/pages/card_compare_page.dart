import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../domain/entities/card_detail.dart';
import '../providers/card_detail_provider.dart';
import '../providers/card_compare_provider.dart';
import 'package:go_router/go_router.dart';
class CardComparePage extends ConsumerWidget {
  const CardComparePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareIds = ref.watch(cardCompareProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BnkAppBar(
        title: '카드 비교 (${compareIds.length}/3)',
        actions: [
          if (compareIds.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(cardCompareProvider.notifier).clear(),
              child: const Text('초기화',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
            ),
        ],
      ),
      body: compareIds.isEmpty
          ? _buildEmpty(context)
          : _buildCompare(ref, compareIds),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            color: AppColors.teal50,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.compare_arrows,
              size: 36, color: AppColors.teal600),
        ),
        const SizedBox(height: 16),
        const Text('비교할 카드를 담아보세요',
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColors.gray800)),
        const SizedBox(height: 6),
        const Text('카드 상세에서 비교 버튼을 눌러주세요',
            style: TextStyle(fontSize: 12, color: AppColors.gray400)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => context.go('/search'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('카드 목록으로'),
        ),
      ],
    ),
  );

  Widget _buildCompare(WidgetRef ref, List<int> ids) {
    final asyncList =
    ids.map((id) => ref.watch(cardDetailProvider(id))).toList();
    final isLoading = asyncList.any((a) => a is AsyncLoading);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final cards = asyncList
        .map((a) => a.asData?.value)
        .whereType<CardDetail>()
        .toList();

    if (cards.isEmpty) {
      return const Center(child: Text('카드 정보를 불러오지 못했습니다.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 카드 헤더
          Row(
            children: [
              const SizedBox(width: 90),
              ...cards.map((c) => Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 56, height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _gradientColors(c.cardType),
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.credit_card,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      c.cardName,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray800),
                    ),
                  ],
                ),
              )),
            ],
          ),

          const SizedBox(height: 16),

          // 비교 테이블
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                _compareRow(
                  label: '카드사',
                  values: cards.map((c) => c.companyName).toList(),
                  isFirst: true,
                ),
                _compareRow(
                  label: '카드 타입',
                  values: cards.map((c) => _typeLabel(c.cardType)).toList(),
                ),
                _compareRow(
                  label: '국내 연회비',
                  values: cards
                      .map((c) => FormatUtil.wonOrFree(c.annualFeeDomestic))
                      .toList(),
                ),
                _compareRow(
                  label: '해외 연회비',
                  values: cards
                      .map((c) => c.annualFeeOverseas > 0
                      ? FormatUtil.won(c.annualFeeOverseas)
                      : '없음')
                      .toList(),
                ),
                _compareRow(
                  label: '주요 혜택',
                  values: cards
                      .map((c) =>
                  c.benefits.isNotEmpty
                      ? c.benefits.first.benefitTitle
                      : '-')
                      .toList(),
                ),
                _compareRow(
                  label: '혜택 수',
                  values: cards
                      .map((c) => '${c.benefits.length}개')
                      .toList(),
                  isLast: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 혜택 상세 비교
          if (cards.any((c) => c.benefits.isNotEmpty))
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('혜택 상세',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray800)),
                  const SizedBox(height: 12),
                  ...cards.map((c) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.teal50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          c.cardName,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.teal800),
                        ),
                      ),
                      ...c.benefits.take(3).map((b) => Padding(
                        padding:
                        const EdgeInsets.only(bottom: 6, left: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ',
                                style: TextStyle(
                                    color: AppColors.teal600,
                                    fontSize: 12)),
                            Expanded(
                              child: Text(
                                b.benefitTitle,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.gray600),
                              ),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(height: 12),
                    ],
                  )),
                ],
              ),
            ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _compareRow({
    required String label,
    required List<String> values,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: isFirst
              ? BorderSide.none
              : const BorderSide(color: AppColors.gray100, width: 0.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.gray400,
                  fontWeight: FontWeight.w500),
            ),
          ),
          ...values.map((v) => Expanded(
            child: Text(
              v,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.gray800),
            ),
          )),
        ],
      ),
    );
  }

  List<Color> _gradientColors(String cardType) => switch (cardType) {
    'CREDIT'  => const [Color(0xFF003040), Color(0xFF00677F)],
    'CHECK'   => const [Color(0xFF2C3E42), Color(0xFF5C7A83)],
    'PREPAID' => const [Color(0xFF8A5A1E), Color(0xFFBA7517)],
    _         => const [AppColors.gray600, AppColors.gray400],
  };

  String _typeLabel(String type) => switch (type) {
    'CREDIT'  => '신용카드',
    'CHECK'   => '체크카드',
    'PREPAID' => '선불카드',
    _         => type,
  };
}