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

  // Material Design error red — AppColors에 error 상수 없으므로 직접 정의
  static const Color _errorRed = Color(0xFFD32F2F);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async    = ref.watch(termsPackageProvider(packageType));
    final agreeMap = ref.watch(termsAgreeProvider);

    return Scaffold(
      appBar: const BnkAppBar(title: '약관 동의'),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(
          child: Text('약관을 불러오지 못했습니다.'),
        ),
        data: (rawList) {
          // safe 타입 변환 — 강제 캐스팅(e as Map) 제거
          final termsList = rawList
              .whereType<Map>()
              .map((e) => TermsModel.fromJson(
            Map<String, dynamic>.from(e),
          ))
              .toList();

          if (termsList.isEmpty) {
            return const Center(child: Text('표시할 약관이 없습니다.'));
          }

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
                              color: _errorRed,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      BnkButton(
                        label: '동의하고 계속',
                        onPressed: allRequiredAgreed
                            ? () => context.pop(true)
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
}