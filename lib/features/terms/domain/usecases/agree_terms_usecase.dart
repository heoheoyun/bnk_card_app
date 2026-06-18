import '../repositories/terms_repository.dart';
class AgreeTermsUsecase {
  final TermsRepository _repo;
  AgreeTermsUsecase(this._repo);
  Future<void> call(List<Map<String, dynamic>> agreements) => _repo.agreeTerms(agreements);
}
