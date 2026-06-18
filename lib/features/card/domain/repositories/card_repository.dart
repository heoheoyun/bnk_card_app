import '../entities/card.dart';
abstract class CardRepository {
  Future<List<Card>> getCardList({String? keyword, String? cardType, int page = 0, int size = 20});
  Future<Map<String, dynamic>> getCardDetail(int cardId);
  Future<List<Card>> getTop3Cards({String? surveyResult});
  Future<Map<String, dynamic>> compareCards(List<int> cardIds);
}
