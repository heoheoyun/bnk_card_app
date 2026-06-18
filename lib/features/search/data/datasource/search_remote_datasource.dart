import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class SearchRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> search(String q, {int page = 0, int size = 20}) async {
    final res = await _dio.get(ApiPaths.search, queryParameters: {'q': q, 'page': page, 'size': size});
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> getSuggestKeywords() async {
    final res = await _dio.get(ApiPaths.suggestKeywords);
    return res.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getPopularKeywords() async {
    final res = await _dio.get(ApiPaths.popularKeywords);
    return res.data['data'] as List<dynamic>;
  }
}
