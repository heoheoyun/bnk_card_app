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

  // ── 알림 설정 저장 ─────────────────────────────────────────────
  /// PUT /api/users/me  Body: { pushEnabled?: bool, marketingAgree?: bool }
  /// 서버(UserService)는 알림 설정만 변경할 경우 currentPassword 검증을 생략한다.
  /// User.applyUpdate 에서 Boolean → 'Y'/'N' 으로 변환되어 저장된다.
  Future<void> updateNotificationSettings({
    bool? pushEnabled,
    bool? marketingAgree,
  }) =>
      _dio.put(ApiPaths.myInfo, data: {
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (marketingAgree != null) 'marketingAgree': marketingAgree,
      });

  // ── FCM 푸시 토큰 등록 / 해제 ──────────────────────────────────
  /// PUT /api/users/me/push-token  Body: { pushToken }
  Future<void> registerPushToken(String token) =>
      _dio.put(ApiPaths.myPushToken, data: {'pushToken': token});

  /// DELETE /api/users/me/push-token  (로그아웃·푸시 OFF 시)
  Future<void> clearPushToken() => _dio.delete(ApiPaths.myPushToken);

  // ── 소비 패턴 조회 ─────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getSpendingPatterns() async {
    final res = await _dio.get(ApiPaths.mySpendingPatterns);
    final raw = res.data['data'];
    if (raw == null) return [];
    return (raw as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ── 소비 패턴 저장 ─────────────────────────────────────────────
  Future<void> saveSpendingPatterns(List<Map<String, dynamic>> items) async {
    await _dio.post(ApiPaths.mySpendingPatterns, data: {'items': items});
  }

  Future<Map<String, dynamic>> getMonthlySpending({int? year, int? month}) async {
    final res = await _dio.get(
      ApiPaths.myMonthlySpending,
      queryParameters: {
        if (year != null) 'year': year,
        if (month != null) 'month': month,
      },
    );
    return res.data['data'] as Map<String, dynamic>;
  }
}