import '../repositories/ai_repository.dart';
class SaveSpendingPatternUsecase {
  final AiRepository _repo;
  SaveSpendingPatternUsecase(this._repo);
  Future<int> call(List<Map<String, dynamic>> patterns) => _repo.updateSpending(patterns);
}
