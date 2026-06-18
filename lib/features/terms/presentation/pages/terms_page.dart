import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_button.dart';
import '../../data/models/terms_model.dart';
import '../providers/terms_provider.dart';
import '../widgets/terms_all_agree_button.dart';
import '../widgets/terms_item_tile.dart';

class TermsPage extends ConsumerWidget {
  final String packageType;
  const TermsPage({super.key, required this.packageType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async    = ref.watch(termsPackageProvider(packageType));
    final agreeMap = ref.watch(termsAgreeProvider);

    return Scaffold(
      appBar: const BnkAppBar(title: '약관 동의'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
            child: Text('약관을 불러오지 못했습니다.')),
        data: (rawList) {
          final termsList = rawList
              .map((e) => TermsModel.fromJson(
              Map<String, dynamic>.from(e as Map)))
              .toList();

          final requiredIds = termsList
              .where((t) => t.required)
              .map((t) => t.termsId)
              .toList();

          final allRequiredAgreed =
          ref.read(termsAgreeProvider.notifier).isAllAgreed(requiredIds);

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TermsAllAgreeButton(termsList: termsList),
                    const SizedBox(height: 12),
                    const Divider(),
                    ...termsList.map(
                          (t) => TermsItemTile(
                        terms: t,
                        agreed: agreeMap[t.termsId] ?? false,
                        onToggle: () => ref
                            .read(termsAgreeProvider.notifier)
                            .toggle(t.termsId),
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!allRequiredAgreed)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text(
                            '필수 약관에 모두 동의해야 계속할 수 있습니다.',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      BnkButton(
                        label: '동의하고 계속',
                        onPressed: allRequiredAgreed
                            ? () =>
                            _onConfirm(context, ref, termsList)
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onConfirm(
      BuildContext context,
      WidgetRef ref,
      List<TermsModel> termsList,
      ) {
    final agreeMap = ref.read(termsAgreeProvider);
    final agreedIds = termsList
        .where((t) => agreeMap[t.termsId] == true)
        .map((t) => t.termsId)
        .toList();
    debugPrint('[TermsPage] agreedIds: $agreedIds');

    switch (packageType) {
      case 'SIGNUP':
        context.go('/signup');
      default:
        context.pop();
    }
  }
}