import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class MypageRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> getMyInfo() async {
    final res = await _dio.get(ApiPaths.myInfo);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateMyInfo(Map<String, dynamic> data) => _dio.put(ApiPaths.myInfo, data: data);

  Future<void> changePassword(String current, String newPassword) =>
      _dio.patch(ApiPaths.myPassword, data: {'currentPassword': current, 'newPassword': newPassword});

  Future<Map<String, dynamic>> getMyCards() async {
    final res = await _dio.get(ApiPaths.myCards);
    return res.data['data'] as Map<String, dynamic>;
  }
}
