import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/card.dart' as entity;

class CardGridItem extends StatelessWidget {
  final entity.Card card;
  const CardGridItem({super.key, required this.card});

  String get _typeLabel {
    switch (card.cardType) {
      case 'CREDIT':  return '신용';
      case 'CHECK':   return '체크';
      case 'PREPAID': return '선불';
      default:        return card.cardType;
    }
  }

  Color get _typeBg {
    switch (card.cardType) {
      case 'CREDIT':  return AppColors.teal50;
      case 'CHECK':   return AppColors.gray100;
      case 'PREPAID': return const Color(0xFFFCEFE0);
      default:        return AppColors.gray100;
    }
  }

  Color get _typeColor {
    switch (card.cardType) {
      case 'CREDIT':  return AppColors.teal800;
      case 'CHECK':   return AppColors.gray600;
      case 'PREPAID': return const Color(0xFF8A5A1E);
      default:        return AppColors.gray600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final benefit = card.topBenefit ?? '';

    return InkWell(
      onTap: () => context.go('/cards/${card.cardId}'),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.gray200, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 64,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              clipBehavior: Clip.antiAlias,
              child: AspectRatio(
                aspectRatio: 1.586,
                child: (card.thumbnailUrl != null && card.thumbnailUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                  imageUrl: card.thumbnailUrl!,
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 14, height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Icon(
                    Icons.credit_card,
                    color: AppColors.gray400,
                    size: 18,
                  ),
                )
                    : Center(
                  child: Icon(
                    Icons.credit_card,
                    color: AppColors.gray400,
                    size: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.cardName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray800,
                    ),
                  ),
                  if (benefit.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      benefit,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _typeBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _typeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _typeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}