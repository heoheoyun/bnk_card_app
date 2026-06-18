import '../../domain/repositories/home_repository.dart';
import '../datasource/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDatasource _ds;
  HomeRepositoryImpl(this._ds);

  @override Future<List<Map<String, dynamic>>> getHomeBanners() async {
    final list = await _ds.getHomeBanners();
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override Future<List<Map<String, dynamic>>> getTop3Cards({String? surveyResult}) async {
    final list = await _ds.getTop3Cards(surveyResult: surveyResult);
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override Future<List<Map<String, dynamic>>> simulateBenefits(List<int> cardIds, Map<int, int> categoryAmounts) async {
    final list = await _ds.simulateBenefits(cardIds, categoryAmounts);
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  @override Future<List<Map<String, dynamic>>> getCardCategories() async {
    final list = await _ds.getCardCategories();
    return list.map((e) => e as Map<String, dynamic>).toList();
  }
}
