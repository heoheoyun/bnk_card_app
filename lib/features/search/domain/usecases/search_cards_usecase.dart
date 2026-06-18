import '../repositories/search_repository.dart';
class SearchCardsUsecase {
  final SearchRepository _repo;
  SearchCardsUsecase(this._repo);
  Future<Map<String, dynamic>> call(String query, {int page = 0}) => _repo.search(query, page: page);
}
