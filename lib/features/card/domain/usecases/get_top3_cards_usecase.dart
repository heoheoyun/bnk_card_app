import '../entities/card.dart';
import '../repositories/card_repository.dart';
class GetTop3CardsUsecase {
  final CardRepository _repo;
  GetTop3CardsUsecase(this._repo);
  Future<List<Card>> call({String? surveyResult}) => _repo.getTop3Cards(surveyResult: surveyResult);
}
