import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import 'package:bnk_card_app/core/constants/app_colors.dart';

/// #16 — 본문을 끝까지 스크롤해야만 '동의' 버튼이 활성화되는 약관 상세 시트.
///
/// 끝까지 읽고 '동의합니다'를 누르면 true, 그냥 닫으면 false 를 반환한다.
/// 호출부에서 true 일 때만 해당 약관을 '동의'로 토글하면 된다.
class ScrollGatedTermsSheet extends StatefulWidget {
  final String title;
  final String content;
  final bool isHtml;

  const ScrollGatedTermsSheet({
    super.key,
    required this.title,
    required this.content,
    this.isHtml = false,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String content,
    bool isHtml = false,
  }) async {
    final res = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ScrollGatedTermsSheet(
        title: title,
        content: content,
        isHtml: isHtml,
      ),
    );
    return res ?? false;
  }

  @override
  State<ScrollGatedTermsSheet> createState() => _ScrollGatedTermsSheetState();
}

class _ScrollGatedTermsSheetState extends State<ScrollGatedTermsSheet> {
  final _scroll = ScrollController();
  bool _reachedBottom = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    // 내용이 짧아 스크롤이 없으면 즉시 활성화 (완독 불가 상태 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients && _scroll.position.maxScrollExtent <= 0) {
        setState(() => _reachedBottom = true);
      }
    });
  }

  void _onScroll() {
    if (_reachedBottom) return;
    final p = _scroll.position;
    if (p.pixels >= p.maxScrollExtent - 24) {
      setState(() => _reachedBottom = true);
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      child: Column(
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 제목
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context, false),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 본문 (스크롤 끝 도달 감지)
          Expanded(
            child: SingleChildScrollView(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              child: widget.isHtml
                  ? Html(data: widget.content)
                  : Text(
                      widget.content,
                      style: const TextStyle(fontSize: 13, height: 1.6),
                    ),
            ),
          ),
          // 동의 버튼 — 끝까지 읽기 전엔 비활성
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _reachedBottom ? AppColors.teal600 : AppColors.gray200,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onPressed: _reachedBottom
                      ? () => Navigator.pop(context, true)
                      : null,
                  child: Text(_reachedBottom ? '동의합니다' : '끝까지 읽어주세요'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
