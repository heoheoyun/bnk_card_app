import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/card_list_provider.dart';
import '../../../terms/presentation/providers/terms_provider.dart';
import '../../../terms/presentation/widgets/terms_files_sheet.dart';

class CardTermsSection extends ConsumerWidget {
  final int cardId;
  const CardTermsSection({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(cardTermsProvider(cardId));

    return termsAsync.when(
      loading: () => const SizedBox.shrink(),
      error:   (_, __) => const SizedBox.shrink(),
      data: (termsList) {
        if (termsList.isEmpty) return const SizedBox.shrink();

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '이용약관',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              ...termsList.map((t) {
                final map      = Map<String, dynamic>.from(t as Map);
                final termsId  = (map['termsId'] as num).toInt();
                final title    = map['title']      as String? ?? '약관';
                final requiredYn = map['requiredYn'] as String? ?? 'N';

                return InkWell(
                  onTap: () => TermsFilesSheet.show(context, termsId, title),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: requiredYn == 'Y' ? AppColors.teal50 : AppColors.gray100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            requiredYn == 'Y' ? '필수' : '선택',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: requiredYn == 'Y' ? AppColors.teal800 : AppColors.gray600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 12, color: AppColors.gray800),
                          ),
                        ),
                        const Icon(Icons.chevron_right, size: 16, color: AppColors.gray400),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}