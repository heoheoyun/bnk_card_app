import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../ai/presentation/providers/spending_pattern_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';

class MySpendingSummary extends ConsumerWidget {
  const MySpendingSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(mySpendingProvider);
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.all(16),
        child: Text('소비 패턴을 불러오지 못했습니다.', style: TextStyle(color: AppColors.textSecondary)),
      ),
      data: (patterns) => patterns.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add_chart),
                label: const Text('소비 패턴 등록하기'),
                onPressed: () {},
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('월 소비 패턴', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                ...patterns.take(5).map((p) => ListTile(
                  dense: true,
                  title: Text(p.categoryName, style: const TextStyle(fontSize: 13)),
                  trailing: Text(FormatUtil.won(p.monthlyAmount),
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500, fontSize: 13)),
                  visualDensity: VisualDensity.compact,
                )),
              ],
            ),
    );
  }
}
