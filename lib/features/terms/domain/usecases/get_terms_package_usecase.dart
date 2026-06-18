import '../repositories/terms_repository.dart';
class GetTermsPackageUsecase {
  final TermsRepository _repo;
  GetTermsPackageUsecase(this._repo);
  Future<List<Map<String, dynamic>>> call(String packageType) => _repo.getTermsPackage(packageType);
}
