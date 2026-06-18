import 'package:flutter/material.dart';
import '../../data/models/card_benefit_model.dart';
import '../../../../core/constants/app_colors.dart';

class CardBenefitSection extends StatelessWidget {
  final List<CardBenefitModel> benefits;
  const CardBenefitSection({super.key, required this.benefits});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
        child: Text('혜택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      ...benefits.map((b) => ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.star_outline, color: AppColors.primary, size: 18),
        ),
        title: Text(b.benefitTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(b.displayText, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        dense: true,
      )),
    ],
  );
}