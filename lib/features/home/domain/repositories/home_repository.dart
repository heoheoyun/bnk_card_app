abstract class HomeRepository {
  Future<List<Map<String, dynamic>>> getHomeBanners();
  Future<List<Map<String, dynamic>>> getTop3Cards({String? surveyResult});
  Future<List<Map<String, dynamic>>> simulateBenefits(List<int> cardIds, Map<int, int> categoryAmounts);
  Future<List<Map<String, dynamic>>> getCardCategories();
}
