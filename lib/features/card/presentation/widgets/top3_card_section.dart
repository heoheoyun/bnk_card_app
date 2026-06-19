import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/card_list_provider.dart';

class Top3CardSection extends ConsumerWidget {
  const Top3CardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top3Async = ref.watch(top3CardsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: Text(
              '이 카드 어때요',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray800,
              ),
            ),
          ),
          const SizedBox(height: 10),
          top3Async.when(
            loading: () => const SizedBox(
              height: 180,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => const SizedBox(
              height: 60,
              child: Center(
                child: Text('추천 카드를 불러오지 못했습니다.',
                    style: TextStyle(color: AppColors.gray400, fontSize: 12)),
              ),
            ),
            data: (cards) {
              if (cards.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(right: 16),
                  itemCount: cards.length > 3 ? 3 : cards.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final card = cards[i];
                    return _Top3Tile(rank: i + 1, card: card);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Top3Tile extends StatelessWidget {
  final int rank;
  final dynamic card;
  const _Top3Tile({required this.rank, required this.card});

  Color get _rankBg {
    switch (rank) {
      case 1:  return AppColors.teal50;
      default: return AppColors.gray100;
    }
  }

  Color get _rankText {
    switch (rank) {
      case 1:  return AppColors.teal800;
      default: return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailUrl = card.thumbnailUrl as String?;
    final benefit = (card.topBenefit ?? '') as String? ?? '';

    return InkWell(
      onTap: () => context.go('/cards/${card.cardId}'),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.gray200),
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.586,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: thumbnailUrl != null && thumbnailUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: thumbnailUrl,
                      fit: BoxFit.contain,
                      placeholder: (_, __) => const Center(
                        child: SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 1.5),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Icon(
                        Icons.credit_card,
                        color: AppColors.gray400,
                        size: 22,
                      ),
                    )
                        : Center(
                      child: Icon(
                        Icons.credit_card,
                        color: AppColors.gray400,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: _rankBg,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _rankText,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              card.cardName as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gray800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              benefit,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                height: 1.3,
                color: AppColors.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}