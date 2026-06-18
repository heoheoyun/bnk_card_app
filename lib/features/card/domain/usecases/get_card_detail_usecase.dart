import '../repositories/card_repository.dart';
class GetCardDetailUsecase {
  final CardRepository _repo;
  GetCardDetailUsecase(this._repo);
  Future<Map<String, dynamic>> call(int cardId) => _repo.getCardDetail(cardId);
}
