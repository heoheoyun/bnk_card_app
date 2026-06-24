import '../repositories/check_application_repository.dart';

class CreateCheckApplicationUsecase {
  final CheckApplicationRepository _repo;
  CreateCheckApplicationUsecase(this._repo);

  Future<int> call({
    required int cardId,
    required List<Map<String, String>> agreedTerms,
  }) {
    return _repo.createApplication(cardId, agreedTerms);
  }
}