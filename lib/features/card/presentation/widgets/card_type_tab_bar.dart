import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CardTypeTabBar extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const CardTypeTabBar({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  static const _tabs = [
    {'label': '전체 카드', 'value': ''},
    {'label': '신용카드', 'value': 'CREDIT'},
    {'label': '체크카드', 'value': 'CHECK'},
    {'label': '선불카드', 'value': 'PREPAID'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final tab = _tabs[i];
          final isSelected = selectedType == tab['value'];
          return InkWell(
            onTap: () => onChanged(tab['value']!),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.teal600 : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.teal600 : AppColors.gray200,
                ),
              ),
              child: Text(
                tab['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : AppColors.gray600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}