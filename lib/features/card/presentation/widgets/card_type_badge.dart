import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
class CardTypeBadge extends StatelessWidget {
  final String cardType;
  const CardTypeBadge({super.key, required this.cardType});
  @override Widget build(BuildContext context) {
    final label = switch (cardType) { 'CREDIT' => '신용', 'CHECK' => '체크', 'PREPAID' => '선불', _ => cardType };
    final color = switch (cardType) { 'CREDIT' => AppColors.credit, 'CHECK' => AppColors.check, _ => AppColors.prepaid };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4), border: Border.all(color: color)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}