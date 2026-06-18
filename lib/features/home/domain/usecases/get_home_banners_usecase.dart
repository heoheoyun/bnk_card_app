import '../repositories/home_repository.dart';
class GetHomeBannersUsecase {
  final HomeRepository _repo;
  GetHomeBannersUsecase(this._repo);
  Future<List<Map<String, dynamic>>> call() => _repo.getHomeBanners();
}
