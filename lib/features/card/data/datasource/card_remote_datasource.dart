import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class CardRemoteDatasource {
  final Dio _dio = DioClient.instance;

  // ── 카드 목록 ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getCardList({
    String? keyword,
    String? cardType,
    int page = 0,
    int size = 20,
  }) async {
    final res = await _dio.get(ApiPaths.cards, queryParameters: {
      if (keyword != null && keyword.isNotEmpty) 'q': keyword,
      if (cardType != null && cardType.isNotEmpty) 'cardType': cardType,
      'page': page,
      'size': size,
    });
    return res.data as Map<String, dynamic>;
  }

  // ── TOP3 추천 ────────────────────────────────────────────────────
  Future<List<dynamic>> getTop3Cards({String? surveyResult}) async {
    final res = await _dio.get(
      ApiPaths.cardsTop3,
      queryParameters: {
        if (surveyResult != null && surveyResult.isNotEmpty)
          'surveyResult': surveyResult,
      },
    );
    return res.data['data'] as List<dynamic>;
  }

  // ── 카드 상세 ────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getCardDetail(int cardId) async {
    final res = await _dio.get(ApiPaths.cardDetail(cardId));
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── 카드 비교 ────────────────────────────────────────────────────
  /// 서버가 List 를 반환하므로 반환 타입을 Map → Map('data': List) 로 감싸서 반환
  Future<Map<String, dynamic>> compareCards(List<int> cardIds) async {
    final res = await _dio.post(
      ApiPaths.cardCompare,
      data: {'cardIds': cardIds},
    );
    // 서버 응답이 { data: [...] } 구조임을 보장
    final raw = res.data;
    if (raw is Map) return raw as Map<String, dynamic>;
    // 혹시 List 로 응답 오는 경우 래핑
    return {'data': raw};
  }
  // ── 카드별 약관 ──────────────────────────────────────────────────
  Future<List<dynamic>> getCardTerms(int cardId) async {
    final res = await _dio.get('/api/cards/$cardId/terms');
    return res.data['data'] as List<dynamic>;
  }




}