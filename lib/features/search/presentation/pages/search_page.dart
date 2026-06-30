import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';
import '../../../../shared/widgets/home_back_scope.dart';
import '../../../card/presentation/providers/card_list_provider.dart';
import '../../../card/presentation/widgets/card_grid_item.dart';
import '../../../card/presentation/widgets/top3_card_section.dart';
import '../../../card/presentation/widgets/card_type_tab_bar.dart';
import '../providers/search_provider.dart';

class SearchPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchPage({super.key, this.initialQuery});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  late final TextEditingController _ctrl;
  late final ScrollController _scrollCtrl;
  String _selectedType = '';

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialQuery ?? '');
    _scrollCtrl = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialQuery?.isNotEmpty == true) {
        _applyFilters();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(cardListPagingProvider.notifier).load();
    }
  }

  void _applyFilters() {
    ref.read(cardListPagingProvider.notifier).setFilters(
      keyword: _ctrl.text.trim().isEmpty ? null : _ctrl.text.trim(),
      cardType: _selectedType.isEmpty ? null : _selectedType,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pagingAsync = ref.watch(cardListPagingProvider);

    return HomeBackScope(
      child: Scaffold(
      appBar: const BnkAppBar(title: '카드 상품', showBack: false),
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                controller: _ctrl,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _applyFilters(),
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '카드명, 혜택 검색...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _ctrl.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _ctrl.clear();
                      setState(() {});
                      _applyFilters();
                    },
                  )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: _PopularKeywordRow(
                onTap: (kw) {
                  _ctrl.text = kw;
                  setState(() {});
                  _applyFilters();
                },
              ),
            ),
          ),

          if (_ctrl.text.trim().isEmpty && _selectedType.isEmpty)
            const SliverToBoxAdapter(child: Top3CardSection()),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
              child: Text(
                '전체 카드',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: CardTypeTabBar(
              selectedType: _selectedType,
              onChanged: (type) {
                setState(() => _selectedType = type);
                _applyFilters();
              },
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          pagingAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
            error: (_, __) => const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('카드 목록을 불러오지 못했습니다.')),
              ),
            ),
            data: (pagingState) {
              final cards = pagingState.cards;
              if (cards.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 60),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off,
                              size: 50, color: AppColors.gray400),
                          SizedBox(height: 10),
                          Text('검색 결과가 없습니다.',
                              style: TextStyle(color: AppColors.gray400)),
                        ],
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      if (i == cards.length) {
                        return pagingState.isLoadingMore
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                            : const SizedBox.shrink();
                      }
                      return CardGridItem(card: cards[i]);
                    },
                    childCount: cards.length + 1,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 90)),
        ],
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 1),
      ),
    );
  }
}

class _PopularKeywordRow extends ConsumerWidget {
  final ValueChanged<String> onTap;
  const _PopularKeywordRow({required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final keywordsAsync = ref.watch(popularKeywordsProvider);

    return keywordsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (keywords) {
        if (keywords.isEmpty) return const SizedBox.shrink();
        return SizedBox(
          height: 28,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: keywords.length,
            separatorBuilder: (_, __) => const SizedBox(width: 6),
            itemBuilder: (context, i) {
              final kw = keywords[i];
              final label = kw is String ? kw : (kw['keyword'] ?? '').toString();
              return InkWell(
                onTap: () => onTap(label),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.teal50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.teal800,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}