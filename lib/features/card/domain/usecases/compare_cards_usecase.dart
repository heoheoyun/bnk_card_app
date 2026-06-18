import '../repositories/card_repository.dart';
class CompareCardsUsecase {
  final CardRepository _repo;
  CompareCardsUsecase(this._repo);
  Future<Map<String, dynamic>> call(List<int> cardIds) => _repo.compareCards(cardIds);
}
