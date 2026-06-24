import '../entities/credit_application.dart';
import '../repositories/credit_application_repository.dart';

class CreateCreditApplicationUsecase {
  final CreditApplicationRepository _repo;
  CreateCreditApplicationUsecase(this._repo);

  Future<int> call({
    required int cardId,
    required List<Map<String, String>> agreedTerms,
  }) {
    return _repo.createApplication(cardId, agreedTerms);
  }
}