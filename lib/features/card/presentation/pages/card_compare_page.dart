import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_error_view.dart';
import '../providers/card_detail_provider.dart';
import '../providers/card_compare_provider.dart';

class CardComparePage extends ConsumerWidget {
  const CardComparePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareIds = ref.watch(cardCompareProvider);

    return Scaffold(
      appBar: BnkAppBar(
        title: '카드 비교 (${compareIds.length}/3)',
        actions: [
          if (compareIds.isNotEmpty)
            TextButton(
              onPressed: () =>
                  ref.read(cardCompareProvider.notifier).clear(),
              child: const Text('전체 삭제',
                  style: TextStyle(color: Colors.red)),
            ),
        ],
      ),
      body: compareIds.isEmpty
          ? _buildEmpty(context)
          : _buildTable(ref, compareIds),
    );
  }

  Widget _buildEmpty(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.compare_arrows,
            size: 72, color: AppColors.textMuted),
        const SizedBox(height: 16),
        const Text('비교할 카드를 담아보세요',
            style:
            TextStyle(fontSize: 16, color: AppColors.textMuted)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('카드 목록으로'),
        ),
      ],
    ),
  );

  Widget _buildTable(WidgetRef ref, List<int> ids) {
    final asyncList =
    ids.map((id) => ref.watch(cardDetailProvider(id))).toList();
    final isLoading = asyncList.any((a) => a is AsyncLoading);
    final hasError  = asyncList.any((a) => a is AsyncError);

    if (isLoading) return const Center(child: CircularProgressIndicator());
    if (hasError)  return const BnkErrorView(message: '카드 정보를 불러오지 못했습니다.');

    final cards = asyncList
        .map((a) => a.asData?.value)
        .whereType<Map<String, dynamic>>()
        .toList();

    const rows = [
      _Row(label: '카드명',     key: 'cardName'),
      _Row(label: '카드사',     key: 'companyName'),
      _Row(label: '국내 연회비', key: 'annualFeeDomestic', isWon: true),
      _Row(label: '해외 연회비', key: 'annualFeeOverseas',  isWon: true),
      _Row(label: '주요 혜택',  key: 'topBenefit'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
              AppColors.primary.withValues(alpha: 0.08)),
          columns: [
            const DataColumn(
                label: Text('항목',
                    style: TextStyle(fontWeight: FontWeight.bold))),
            ...cards.map((c) => DataColumn(
              label: Text(
                c['cardName'] as String? ?? '',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            )),
          ],
          rows: rows.map((row) {
            return DataRow(cells: [
              DataCell(Text(row.label,
                  style: const TextStyle(
                      color: AppColors.textMuted))),
              ...cards.map((c) {
                final val = c[row.key];
                final display = (row.isWon && val is int)
                    ? FormatUtil.wonOrFree(val)
                    : (val?.toString() ?? '-');
                return DataCell(Text(display));
              }),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}

class _Row {
  final String label;
  final String key;
  final bool   isWon;
  const _Row({required this.label, required this.key, this.isWon = false});
}