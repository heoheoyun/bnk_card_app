import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';

class AiCardResultCard extends StatelessWidget {
  final Map<String, dynamic> card;
  final int rank;
  const AiCardResultCard({super.key, required this.card, required this.rank});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => context.go('/cards/${card['cardId']}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          // 순위
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
          const SizedBox(width: 12),
          // 썸네일
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: card['thumbnailUrl'] != null
                ? CachedNetworkImage(imageUrl: card['thumbnailUrl'] as String, width: 60, height: 38, fit: BoxFit.cover)
                : Container(width: 60, height: 38, color: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.credit_card, color: AppColors.primary, size: 20)),
          ),
          const SizedBox(width: 12),
          // 정보
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(card['cardName'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 2),
            Text(FormatUtil.wonOrFree(card['annualFeeDomestic'] as int? ?? 0),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ])),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ]),
      ),
    ),
  );
}