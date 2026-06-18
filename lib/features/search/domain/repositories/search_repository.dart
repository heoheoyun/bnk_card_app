abstract class SearchRepository {
  Future<Map<String, dynamic>> search(String q, {int page = 0});
  Future<List<String>> getSuggestKeywords();
  Future<List<Map<String, dynamic>>> getPopularKeywords();
}
