import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class AiRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> chat(String message, String sessionId) async {
    final res = await _dio.post(ApiPaths.chat, data: {'message': message, 'sessionId': sessionId});
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getChatHistory(String sessionId) async {
    final res = await _dio.get(ApiPaths.chatHistory, queryParameters: {'sessionId': sessionId});
    return res.data['data'] as List<dynamic>;
  }

  Future<List<dynamic>> getMySpending() async {
    final res = await _dio.get(ApiPaths.mySpending);
    return res.data['data'] as List<dynamic>;
  }

  Future<int> updateSpending(List<Map<String, dynamic>> patterns) async {
    final res = await _dio.put(ApiPaths.mySpending, data: {'patterns': patterns});
    return res.data['data'] as int;
  }
}
