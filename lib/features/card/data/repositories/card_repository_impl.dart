import '../../domain/entities/card.dart';
import '../../domain/repositories/card_repository.dart';
import '../datasource/card_remote_datasource.dart';
import '../models/card_model.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDatasource _ds;
  CardRepositoryImpl(this._ds);

  @override Future<List<Card>> getCardList({String? keyword, String? cardType, int page = 0, int size = 20}) async {
    final data = await _ds.getCardList(keyword: keyword, cardType: cardType, page: page, size: size);
    final items = (data['data']?['content'] as List? ?? []);
    return items.map((e) => _toEntity(CardModel.fromJson(Map<String, dynamic>.from(e as Map)))).toList();
  }

  @override Future<Map<String, dynamic>> getCardDetail(int cardId) => _ds.getCardDetail(cardId);

  @override Future<List<Card>> getTop3Cards({String? surveyResult}) async {
    final list = await _ds.getTop3Cards(surveyResult: surveyResult);
    return list.map((e) => _toEntity(CardModel.fromJson(Map<String, dynamic>.from(e as Map)))).toList();
  }

  @override Future<Map<String, dynamic>> compareCards(List<int> cardIds) => _ds.compareCards(cardIds);

  Card _toEntity(CardModel m) => Card(
    cardId: m.cardId, cardName: m.cardName, companyName: m.companyName,
    cardType: m.cardType, annualFeeDomestic: m.annualFeeDomestic, annualFeeOverseas: m.annualFeeOverseas,
    summaryDescription: m.summaryDescription, thumbnailUrl: m.thumbnailUrl,
  );
}