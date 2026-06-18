import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';

class MypageRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> getMyInfo() async {
    final res = await _dio.get(ApiPaths.myInfo);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateMyInfo(Map<String, dynamic> data) =>
      _dio.put(ApiPaths.myInfo, data: data);

  Future<void> changePassword(String current, String newPassword) =>
      _dio.patch(ApiPaths.myPassword,
          data: {'currentPassword': current, 'newPassword': newPassword});

  Future<Map<String, dynamic>> getMyCards() async {
    final res = await _dio.get(ApiPaths.myCards);
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── 소비 패턴 조회 ─────────────────────────────────────────────
  /// GET /api/users/me/spending-patterns
  /// 서버 응답: { "data": [ { "categoryId": 1, "categoryCode": "FOOD",
  ///              "monthlyAmount": 300000, "source": "MANUAL" }, ... ] }
  Future<List<Map<String, dynamic>>> getSpendingPatterns() async {
    final res = await _dio.get(ApiPaths.mySpendingPatterns);
    final raw = res.data['data'];
    if (raw == null) return [];
    return (raw as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ── 소비 패턴 저장 ─────────────────────────────────────────────
  /// POST /api/users/me/spending-patterns
  /// Body: { "items": [ { "categoryId": 1, "monthlyAmount": 300000 }, ... ] }
  Future<void> saveSpendingPatterns(List<Map<String, dynamic>> items) async {
    await _dio.post(ApiPaths.mySpendingPatterns, data: {'items': items});
  }
}