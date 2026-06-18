import '../entities/card.dart';
import '../entities/card_detail.dart';

abstract class CardRepository {
  Future<List<Card>> getCardList({
    String? keyword,
    String? cardType,
    int page = 0,
    int size = 20,
  });

  /// 카드 상세 — [CardDetail] Entity 반환 (Map raw 제거)
  Future<CardDetail> getCardDetail(int cardId);

  Future<List<Card>> getTop3Cards({String? surveyResult});

  Future<Map<String, dynamic>> compareCards(List<int> cardIds);
}