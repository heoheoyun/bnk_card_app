import '../repositories/search_repository.dart';
class GetPopularKeywordsUsecase {
  final SearchRepository _repo;
  GetPopularKeywordsUsecase(this._repo);
  Future<List<Map<String, dynamic>>> call() => _repo.getPopularKeywords();
}
