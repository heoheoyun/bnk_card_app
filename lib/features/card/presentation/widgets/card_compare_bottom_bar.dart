import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/card_compare_provider.dart';
import '../../../../core/constants/app_colors.dart';

class CardCompareBottomBar extends ConsumerWidget {
  const CardCompareBottomBar({super.key});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(cardCompareProvider);
    if (ids.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.primary,
      child: Row(children: [
        Text('${ids.length}개 선택됨', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        const Spacer(),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.primary),
          onPressed: ids.length >= 2 ? () => context.go('/cards/compare') : null,
          child: const Text('비교하기'),
        ),
      ]),
    );
  }
}
