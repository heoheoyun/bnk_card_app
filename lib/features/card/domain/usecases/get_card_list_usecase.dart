import '../entities/card.dart';
import '../repositories/card_repository.dart';
class GetCardListUsecase {
  final CardRepository _repo;
  GetCardListUsecase(this._repo);
  Future<List<Card>> call({String? keyword, String? cardType, int page = 0}) =>
      _repo.getCardList(keyword: keyword, cardType: cardType, page: page);
}
