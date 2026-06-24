import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../mypage/presentation/providers/mypage_provider.dart';

class SpendingSummaryCard extends ConsumerWidget {
  const SpendingSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monthlyAsync = ref.watch(monthlySpendingProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: monthlyAsync.when(
        loading: () => const SizedBox(
          height: 60,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const Text(
          '이용금액을 불러오지 못했습니다.',
          style: TextStyle(fontSize: 12, color: AppColors.gray400),
        ),
        data: (data) {
          final cards = (data['cards'] as List? ?? [])
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

          if (cards.isEmpty) {
            return const Text(
              '이번달 이용 내역이 없습니다.',
              style: TextStyle(fontSize: 12, color: AppColors.gray400),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '카드별 이용금액',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray800,
                ),
              ),
              const SizedBox(height: 12),
              ...cards.asMap().entries.map((entry) {
                final i    = entry.key;
                final card = entry.value;
                final cardName = card['cardName'] as String? ?? '카드';
                final amount   = (card['amount'] as num?)?.toInt() ?? 0;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Container(
                        width: 28, height: 5,
                        decoration: BoxDecoration(
                          color: i == 0 ? AppColors.teal600 : AppColors.teal200,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cardName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.gray800),
                        ),
                      ),
                      Text(
                        _formatAmount(amount),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.teal900,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  String _formatAmount(int amount) {
    return '${amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    )}원';
  }
}