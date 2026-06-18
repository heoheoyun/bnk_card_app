import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';

class CardCompareTable extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  const CardCompareTable({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Table(
        border: TableBorder.all(color: AppColors.divider, width: 0.5),
        columnWidths: {
          0: const FixedColumnWidth(100),
          for (int i = 1; i <= cards.length; i++) i: const FixedColumnWidth(150),
        },
        children: [
          // 헤더 행
          TableRow(
            decoration: const BoxDecoration(color: AppColors.primary),
            children: [
              _cell('항목', isHeader: true),
              ...cards.map((c) => _cell(c['cardName'] as String? ?? '', isHeader: true)),
            ],
          ),
          _row('카드 유형', cards.map((c) => c['cardType'] as String? ?? '').toList()),
          _row('국내 연회비', cards.map((c) => FormatUtil.wonOrFree(c['annualFeeDomestic'] as int? ?? 0)).toList()),
          _row('해외 연회비', cards.map((c) => FormatUtil.wonOrFree(c['annualFeeOverseas'] as int? ?? 0)).toList()),
          _row('대표 혜택', cards.map((c) {
            final b = (c['benefits'] as List?)?.firstOrNull as Map?;
            return b?['displayText'] as String? ?? '-';
          }).toList()),
        ],
      ),
    );
  }

  TableRow _row(String label, List<String> values) => TableRow(children: [
    _cell(label, isLabel: true),
    ...values.map((v) => _cell(v)),
  ]);

  Widget _cell(String text, {bool isHeader = false, bool isLabel = false}) => Padding(
    padding: const EdgeInsets.all(10),
    child: Text(text,
      textAlign: isHeader || isLabel ? TextAlign.center : TextAlign.center,
      style: TextStyle(
        color: isHeader ? Colors.white : isLabel ? AppColors.primary : AppColors.textPrimary,
        fontWeight: isHeader || isLabel ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
    ),
  );
}