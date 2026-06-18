import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';
import '../../../../core/constants/app_colors.dart';

class RecommendKeywordList extends ConsumerWidget {
  final void Function(String keyword) onTap;
  const RecommendKeywordList({super.key, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(suggestKeywordsProvider);
    return asyncValue.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '추천 검색어',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: list.map((k) {
              final keyword = k is Map ? k['keyword'] as String : k.toString();
              return GestureDetector(
                onTap: () => onTap(keyword),
                child: Chip(
                  label: Text(keyword, style: const TextStyle(fontSize: 12)),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                  side: BorderSide(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}