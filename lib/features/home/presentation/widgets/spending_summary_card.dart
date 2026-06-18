import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class SpendingSummaryCard extends StatelessWidget {
  const SpendingSummaryCard({super.key});

  final List<Map<String, dynamic>> _items = const [
    {'name': '다이나믹 카드', 'amount': '82,400원', 'primary': true},
    {'name': '그린 체크카드', 'amount': '45,000원', 'primary': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
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
          ..._items.map((item) => _SpendRow(item: item)),
        ],
      ),
    );
  }
}

class _SpendRow extends StatelessWidget {
  final Map<String, dynamic> item;
  const _SpendRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Container(
            width: 28, height: 5,
            decoration: BoxDecoration(
              color: item['primary'] ? AppColors.teal600 : AppColors.teal200,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item['name'],
              style: const TextStyle(fontSize: 12, color: AppColors.gray800),
            ),
          ),
          Text(
            item['amount'],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.teal900,
            ),
          ),
        ],
      ),
    );
  }
}