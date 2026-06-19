import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/card_remote_datasource.dart';
import '../../data/repositories/card_repository_impl.dart';
import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../../domain/usecases/get_card_list_usecase.dart';
import '../../domain/usecases/get_top3_cards_usecase.dart';

final cardDatasourceProvider = Provider<CardRemoteDatasource>(
      (_) => CardRemoteDatasource(),
);

final cardRepositoryProvider = Provider<CardRepository>(
      (ref) => CardRepositoryImpl(ref.watch(cardDatasourceProvider)),
);

final getCardListUsecaseProvider = Provider<GetCardListUsecase>(
      (ref) => GetCardListUsecase(ref.watch(cardRepositoryProvider)),
);

/// 카드 목록 조회 파라미터 (keyword + cardType 묶음)
class CardListParams {
  final String? keyword;
  final String? cardType;
  const CardListParams({this.keyword, this.cardType});

  @override
  bool operator ==(Object other) =>
      other is CardListParams &&
          other.keyword == keyword &&
          other.cardType == cardType;

  @override
  int get hashCode => Object.hash(keyword, cardType);
}

final cardListProvider =
FutureProvider.family<List<Card>, CardListParams>(
      (ref, params) => ref.watch(getCardListUsecaseProvider)(
    keyword: params.keyword,
    cardType: params.cardType,
  ),
);

final getTop3CardsUsecaseProvider = Provider<GetTop3CardsUsecase>(
      (ref) => GetTop3CardsUsecase(ref.watch(cardRepositoryProvider)),
);

final top3CardsProvider = FutureProvider<List<Card>>(
      (ref) => ref.watch(getTop3CardsUsecaseProvider)(),
);

class CardListPagingState {
  final List<Card> cards;
  final int page;
  final bool hasNext;
  final bool isLoadingMore;

  const CardListPagingState({
    this.cards = const [],
    this.page = 0,
    this.hasNext = true,
    this.isLoadingMore = false,
  });

  CardListPagingState copyWith({
    List<Card>? cards,
    int? page,
    bool? hasNext,
    bool? isLoadingMore,
  }) {
    return CardListPagingState(
      cards: cards ?? this.cards,
      page: page ?? this.page,
      hasNext: hasNext ?? this.hasNext,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class CardListPagingNotifier extends StateNotifier<AsyncValue<CardListPagingState>> {
  final CardRemoteDatasource _ds;
  String? _keyword;
  String? _cardType;

  CardListPagingNotifier(this._ds) : super(const AsyncLoading()) {
    load(reset: true);
  }

  Future<void> setFilters({String? keyword, String? cardType}) async {
    _keyword = keyword;
    _cardType = cardType;
    await load(reset: true);
  }

  Future<void> load({bool reset = false}) async {
    final current = state.valueOrNull ?? const CardListPagingState();

    if (reset) {
      state = const AsyncLoading();
    } else {
      if (current.isLoadingMore || !current.hasNext) return;
      state = AsyncData(current.copyWith(isLoadingMore: true));
    }

    try {
      final nextPage = reset ? 0 : current.page + 1;
      final raw = await _ds.getCardList(
        keyword: _keyword,
        cardType: _cardType,
        page: nextPage,
        size: 20,
      );
      final data = raw['data'] as Map<String, dynamic>;
      final content = (data['content'] as List)
          .map((e) => _mapToEntity(Map<String, dynamic>.from(e as Map)))
          .toList();
      final hasNext = data['hasNext'] as bool? ?? false;

      final mergedCards = reset ? content : [...current.cards, ...content];

      state = AsyncData(CardListPagingState(
        cards: mergedCards,
        page: nextPage,
        hasNext: hasNext,
        isLoadingMore: false,
      ));
    } catch (e, st) {
      if (reset) {
        state = AsyncError(e, st);
      } else {
        state = AsyncData(current.copyWith(isLoadingMore: false));
      }
    }
  }

  Card _mapToEntity(Map<String, dynamic> j) {
    return Card(
      cardId: j['cardId'] as int,
      cardName: j['cardName'] as String,
      companyName: j['companyName'] as String,
      cardType: j['cardType'] as String,
      annualFeeDomestic: (j['annualFeeDomestic'] as num?)?.toInt() ?? 0,
      annualFeeOverseas: (j['annualFeeOverseas'] as num?)?.toInt() ?? 0,
      summaryDescription: j['summaryDescription'] as String?,
      thumbnailUrl: j['thumbnailUrl'] as String?,
      topBenefit: j['topBenefit'] as String?,
    );
  }
}

final cardListPagingProvider =
StateNotifierProvider.autoDispose<CardListPagingNotifier, AsyncValue<CardListPagingState>>(
      (ref) => CardListPagingNotifier(ref.watch(cardDatasourceProvider)),
);

final cardTermsProvider =
FutureProvider.family<List<dynamic>, int>((ref, cardId) {
  final ds = ref.watch(cardDatasourceProvider);
  return ds.getCardTerms(cardId);
});