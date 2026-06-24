import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/terms_provider.dart';

class TermsFilesSheet extends ConsumerWidget {
  final int    termsId;
  final String title;
  const TermsFilesSheet({super.key, required this.termsId, required this.title});

  static Future<void> show(BuildContext context, int termsId, String title) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => TermsFilesSheet(termsId: termsId, title: title),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filesAsync = ref.watch(termsFilesProvider(termsId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize:     0.3,
      maxChildSize:     0.9,
      expand: false,
      builder: (context, scrollController) => Column(
        children: [
          // 핸들
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
              error:   (_, __) => const Center(child: Text('파일을 불러오지 못했습니다.')),
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
                final images = fileMaps
                    .where((f) => f['fileType'] == 'IMAGE')
                    .toList();

                if (images.isEmpty) {
                  return const Center(
                    child: Text('표시할 이미지가 없습니다.',
                        style: TextStyle(color: AppColors.gray400)),
                  );
                }

                return ListView.builder(
                  controller:  scrollController,
                  padding:     const EdgeInsets.all(16),
                  itemCount:   images.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CachedNetworkImage(
                      imageUrl:     images[i]['filePath'] as String? ?? '',
                      placeholder:  (_, __) => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget:  (_, __, ___) => const Icon(Icons.broken_image),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}