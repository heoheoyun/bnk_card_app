import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/terms_provider.dart';
import '../../data/models/terms_model.dart';
import '../../../../core/constants/app_colors.dart';

class TermsAllAgreeButton extends ConsumerWidget {
  final List<TermsModel> termsList;
  const TermsAllAgreeButton({super.key, required this.termsList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agreeMap  = ref.watch(termsAgreeProvider);
    final allAgreed = termsList.every((t) => agreeMap[t.termsId] == true);

    return GestureDetector(
      onTap: () => ref.read(termsAgreeProvider.notifier)
          .agreeAll(termsList.map((t) => t.termsId).toList()),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: allAgreed ? AppColors.primary.withValues(alpha: 0.06) : Colors.grey.shade50,
          border: Border.all(color: allAgreed ? AppColors.primary : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(children: [
          Icon(allAgreed ? Icons.check_circle : Icons.check_circle_outline,
              color: allAgreed ? AppColors.primary : Colors.grey),
          const SizedBox(width: 10),
          const Text('전체 동의', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          Text('필수 및 선택 약관 포함', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        ]),
      ),
    );
  }
}