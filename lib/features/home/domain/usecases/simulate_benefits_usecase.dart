import '../repositories/home_repository.dart';
class SimulateBenefitsUsecase {
  final HomeRepository _repo;
  SimulateBenefitsUsecase(this._repo);
  Future<List<Map<String, dynamic>>> call(List<int> cardIds, Map<int, int> categoryAmounts) =>
      _repo.simulateBenefits(cardIds, categoryAmounts);
}
