import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../providers/search_provider.dart';
import '../widgets/popular_keyword_list.dart';
import '../widgets/search_result_list.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery ?? '');
    if (widget.initialQuery?.isNotEmpty == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(searchProvider.notifier).search(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _search(String q) {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    ref.read(searchProvider.notifier).search(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: const BnkAppBar(title: '검색', showBack: false),
      body: Column(
        children: [
          // ── 검색바 ────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: '카드명, 혜택, 카드사 검색',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _ctrl.clear();
                    ref.read(searchProvider.notifier).clear();
                    setState(() {});
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── 결과 영역 ──────────────────────────────────────────
          Expanded(
            child: searchState.when(
              loading: () =>
              const Center(child: CircularProgressIndicator()),
              error: (_, __) =>
              const Center(child: Text('검색 중 오류가 발생했습니다.')),
              data: (result) {
                if (result == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text('인기 검색어',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ),
                      Expanded(
                        child: PopularKeywordList(
                          onTap: (kw) {
                            _ctrl.text = kw;
                            _search(kw);
                          },
                        ),
                      ),
                    ],
                  );
                }

                final content =
                    (result['page'] as Map?)?['content'] as List? ?? [];
                final total =
                    (result['page'] as Map?)?['totalCount'] as int? ?? 0;

                if (content.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 60, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text('"${_ctrl.text}" 검색 결과가 없습니다.',
                            style: const TextStyle(
                                color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }

                return SearchResultList(
                    results: content, totalCount: total);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 1),
    );
  }
}