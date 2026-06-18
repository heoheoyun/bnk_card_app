import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class HomeRemoteDatasource {
  final Dio _dio = DioClient.instance;

  /// GET /api/home/banners  — 비회원: 조회수TOP3 / 회원: 소비패턴 카테고리 기반
  Future<List<dynamic>> getHomeBanners() async {
    final res = await _dio.get(ApiPaths.homeBanners);
    return res.data['data'] as List<dynamic>;
  }

  /// GET /api/cards/top3?surveyResult=...
  Future<List<dynamic>> getTop3Cards({String? surveyResult}) async {
    final res = await _dio.get(
      ApiPaths.cardsTop3,
      queryParameters: {if (surveyResult != null && surveyResult.isNotEmpty) 'surveyResult': surveyResult},
    );
    return res.data['data'] as List<dynamic>;
  }

  /// POST /api/cards/simulate — 혜택 시뮬레이션
  Future<List<dynamic>> simulateBenefits(List<int> cardIds, Map<int, int> categoryAmounts) async {
    final res = await _dio.post('/api/cards/simulate', data: {
      'cardIds':         cardIds,
      'categoryAmounts': categoryAmounts,
    });
    return res.data['data'] as List<dynamic>;
  }

  /// GET /api/cards/categories
  Future<List<dynamic>> getCardCategories() async {
    final res = await _dio.get(ApiPaths.cardCategories);
    return res.data['data'] as List<dynamic>;
  }
}
