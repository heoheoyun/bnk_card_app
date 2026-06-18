import '../../domain/repositories/search_repository.dart';
import '../datasource/search_remote_datasource.dart';

class SearchRepositoryImpl implements SearchRepository {
  final SearchRemoteDatasource _ds;
  SearchRepositoryImpl(this._ds);

  @override Future<Map<String, dynamic>> search(String q, {int page = 0}) => _ds.search(q, page: page);

  @override Future<List<String>> getSuggestKeywords() async {
    final list = await _ds.getSuggestKeywords();
    return list.map((e) => (e as Map)['keyword'] as String).toList();
  }

  @override Future<List<Map<String, dynamic>>> getPopularKeywords() async {
    final list = await _ds.getPopularKeywords();
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
