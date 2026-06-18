import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/card_compare_provider.dart';
import 'card_type_badge.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';

class CardListItem extends ConsumerWidget {
  final Map<String, dynamic> card;
  const CardListItem({super.key, required this.card});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareIds  = ref.watch(cardCompareProvider);
    final cardId      = card['cardId'] as int;
    final isComparing = compareIds.contains(cardId);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.go('/cards/$cardId'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // 카드 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: card['thumbnailUrl'] != null
                  ? CachedNetworkImage(imageUrl: card['thumbnailUrl'] as String, width: 80, height: 50, fit: BoxFit.cover)
                  : Container(width: 80, height: 50, color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Icon(Icons.credit_card, color: AppColors.primary)),
            ),
            const SizedBox(width: 12),
            // 카드 정보
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CardTypeBadge(cardType: card['cardType'] as String? ?? ''),
                const SizedBox(width: 6),
                Expanded(child: Text(card['cardName'] as String? ?? '',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis)),
              ]),
              const SizedBox(height: 4),
              Text(card['companyName'] as String? ?? '',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 4),
              Text(FormatUtil.wonOrFree(card['annualFeeDomestic'] as int? ?? 0),
                  style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w500)),
            ])),
            // 비교 담기 버튼
            GestureDetector(
              onTap: () => ref.read(cardCompareProvider.notifier).toggle(cardId),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isComparing ? AppColors.primary : Colors.transparent,
                  border: Border.all(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(isComparing ? '비교중' : '비교',
                    style: TextStyle(color: isComparing ? Colors.white : AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}