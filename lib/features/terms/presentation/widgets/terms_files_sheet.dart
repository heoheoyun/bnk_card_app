import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/terms_provider.dart';

/// 약관/상품안내장 이미지를 바텀시트로 보여주고,
/// 끝까지 스크롤한 뒤 '확인'을 눌러야 true 를 반환한다.
/// (호출부: TermsItemTile 의 '보기' 버튼 → 반환값이 true 일 때만 _viewed 처리)
class TermsFilesSheet extends ConsumerStatefulWidget {
  final int    termsId;
  final String title;
  const TermsFilesSheet({super.key, required this.termsId, required this.title});

  /// 끝까지 읽고 확인을 누르면 true 반환. 그냥 닫으면 null.
  static Future<bool?> show(BuildContext context, int termsId, String title) {
    return showModalBottomSheet<bool>(
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
  ConsumerState<TermsFilesSheet> createState() => _TermsFilesSheetState();
}

class _TermsFilesSheetState extends ConsumerState<TermsFilesSheet> {
  bool _reachedEnd = false;

  /// 스크롤이 끝(또는 끝 근처 24px)에 도달했는지 검사.
  /// 콘텐츠가 화면보다 짧아 스크롤이 없으면 즉시 읽음 처리.
  void _check(ScrollController c) {
    if (!c.hasClients) return;
    final pos = c.position;
    if (pos.maxScrollExtent <= 0) {
      if (!_reachedEnd) setState(() => _reachedEnd = true);
      return;
    }
    if (pos.pixels >= pos.maxScrollExtent - 24) {
      if (!_reachedEnd) setState(() => _reachedEnd = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filesAsync = ref.watch(termsFilesProvider(widget.termsId));

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
              widget.title,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          const Divider(height: 1, color: AppColors.gray100),

          Expanded(
            child: filesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (_, __) => const Center(child: Text('파일을 불러오지 못했습니다.')),
              data: (files) {
                final fileMaps = files
                    .map((f) => Map<String, dynamic>.from(f as Map))
                    .toList();
                final images = fileMaps
                    .where((f) => f['fileType'] == 'IMAGE')
                    .toList();

                if (images.isEmpty) {
                  // 표시할 이미지가 없으면 읽을 것이 없으므로 자동 통과
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && !_reachedEnd) {
                      setState(() => _reachedEnd = true);
                    }
                  });
                  return const Center(
                    child: Text('표시할 내용이 없습니다.',
                        style: TextStyle(color: AppColors.gray400)),
                  );
                }

                // 첫 레이아웃/이미지 로드 후 스크롤 가능 여부 재검사
                WidgetsBinding.instance
                    .addPostFrameCallback((_) => _check(scrollController));

                return NotificationListener<ScrollNotification>(
                  onNotification: (_) {
                    _check(scrollController);
                    return false;
                  },
                  child: ListView.builder(
                    controller:  scrollController,
                    padding:     const EdgeInsets.all(16),
                    itemCount:   images.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CachedNetworkImage(
                        imageUrl:    images[i]['filePath'] as String? ?? '',
                        placeholder: (_, __) => const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 하단 확인 버튼 — 끝까지 읽어야 활성화
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed:
                  _reachedEnd ? () => Navigator.pop(context, true) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:         AppColors.primary,
                    disabledBackgroundColor: AppColors.gray200,
                    foregroundColor:         Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(_reachedEnd ? '확인했습니다' : '끝까지 확인해 주세요'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}