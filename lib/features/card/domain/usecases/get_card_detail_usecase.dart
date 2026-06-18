import '../entities/card_detail.dart';
import '../repositories/card_repository.dart';

class GetCardDetailUsecase {
  final CardRepository _repo;
  GetCardDetailUsecase(this._repo);

  Future<CardDetail> call(int cardId) => _repo.getCardDetail(cardId);
}