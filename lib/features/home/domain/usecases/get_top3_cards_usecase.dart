import '../repositories/home_repository.dart';
class GetTop3CardsUsecase {
  final HomeRepository _repo;
  GetTop3CardsUsecase(this._repo);
  Future<List<Map<String, dynamic>>> call({String? surveyResult}) =>
      _repo.getTop3Cards(surveyResult: surveyResult);
}
