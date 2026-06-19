import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/card_list_provider.dart';
import '../../../terms/presentation/providers/terms_provider.dart';
class CardTermsSection extends ConsumerWidget {
  final int cardId;
  const CardTermsSection({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final termsAsync = ref.watch(cardTermsProvider(cardId));

    return termsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
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
                final map = Map<String, dynamic>.from(t as Map);
                final termsId = (map['termsId'] as num).toInt();
                final title = map['title'] as String? ?? '약관';
                final requiredYn = map['requiredYn'] as String? ?? 'N';

                return InkWell(
                  onTap: () => _showTermsFiles(context, termsId, title),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: requiredYn == 'Y'
                                ? AppColors.teal50
                                : AppColors.gray100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            requiredYn == 'Y' ? '필수' : '선택',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: requiredYn == 'Y'
                                  ? AppColors.teal800
                                  : AppColors.gray600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.gray800),
                          ),
                        ),
                        const Icon(Icons.chevron_right,
                            size: 16, color: AppColors.gray400),
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

  void _showTermsFiles(BuildContext context, int termsId, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _TermsFilesSheet(termsId: termsId, title: title),
    );
  }
}

class _TermsFilesSheet extends ConsumerWidget {
  final int termsId;
  final String title;
  const _TermsFilesSheet({required this.termsId, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(termsFilesProvider(termsId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 36, height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
            const Divider(height: 1, color: AppColors.gray100),
            Expanded(
              child: filesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('파일을 불러오지 못했습니다.')),
                data: (files) {
                  if (files.isEmpty) {
                    return const Center(
                      child: Text('등록된 파일이 없습니다.',
                          style: TextStyle(color: AppColors.gray400)),
                    );
                  }

                  final fileMaps = files
                      .map((f) => Map<String, dynamic>.from(f as Map))
                      .toList();
                  final pdfs = fileMaps
                      .where((f) => f['fileType'] == 'PDF')
                      .toList();
                  final images = fileMaps
                      .where((f) => f['fileType'] == 'IMAGE')
                      .toList();

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    children: [
                      if (pdfs.isNotEmpty) ...[
                        const Text('PDF 원본',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        ...pdfs.map((f) => _FileTile(
                          icon: Icons.picture_as_pdf_outlined,
                          name: f['originalName'] as String? ?? '약관.pdf',
                          url: f['filePath'] as String? ?? '',
                        )),
                        const SizedBox(height: 16),
                      ],
                      if (images.isNotEmpty) ...[
                        Text('페이지 미리보기 (총 ${images.length}페이지)',
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        ...images.asMap().entries.map((entry) => _FileTile(
                          icon: Icons.image_outlined,
                          name: '페이지 ${entry.key + 1}',
                          url: entry.value['filePath'] as String? ?? '',
                        )),
                      ],
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FileTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String url;
  const _FileTile({required this.icon, required this.name, required this.url});

  Future<void> _openUrl() async {
    if (url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _openUrl,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.teal600),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: AppColors.gray800),
              ),
            ),
            const Icon(Icons.download_outlined, size: 16, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}