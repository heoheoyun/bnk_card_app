import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class CardRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> getCardList({String? keyword, String? cardType, int page = 0, int size = 20}) async {
    final res = await _dio.get(ApiPaths.cards, queryParameters: {
      if (keyword != null) 'keyword': keyword,
      if (cardType != null) 'cardType': cardType,
      'page': page, 'size': size,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getCardDetail(int cardId) async {
    final res = await _dio.get(ApiPaths.cardDetail(cardId));
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getTop3Cards({String? surveyResult}) async {
    final res = await _dio.get(ApiPaths.cardsTop3,
        queryParameters: {if (surveyResult != null) 'surveyResult': surveyResult});
    return res.data['data'] as List<dynamic>;
  }

  Future<Map<String, dynamic>> compareCards(List<int> cardIds) async {
    final res = await _dio.post(ApiPaths.cardCompare, data: {'cardIds': cardIds});
    return res.data['data'] as Map<String, dynamic>;
  }
}
