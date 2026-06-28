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

  // ── #7 비밀번호 변경 ───────────────────────────────────────────
  // 서버 계약: PATCH /api/users/me/password
  //   body { currentPassword, newPassword, newPasswordConfirm }
  // 기존 코드는 newPasswordConfirm 누락 → 서버에서 U009/검증 실패로 변경 불가였다.
  Future<void> changePassword(
      String current,
      String newPassword,
      String newPasswordConfirm,
      ) =>
      _dio.patch(ApiPaths.myPassword, data: {
        'currentPassword': current,
        'newPassword': newPassword,
        'newPasswordConfirm': newPasswordConfirm,
      });

  Future<Map<String, dynamic>> getMyCards() async {
    final res = await _dio.get(ApiPaths.myCards);
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── 알림 설정 저장 ─────────────────────────────────────────────
  /// PUT /api/users/me  Body: { pushEnabled?: bool, marketingAgree?: bool }
  /// 서버(UserService)는 알림 설정만 변경할 경우 currentPassword 검증을 생략한다.
  Future<void> updateNotificationSettings({
    bool? pushEnabled,
    bool? marketingAgree,
  }) =>
      _dio.put(ApiPaths.myInfo, data: {
        if (pushEnabled != null) 'pushEnabled': pushEnabled,
        if (marketingAgree != null) 'marketingAgree': marketingAgree,
      });

  // ── FCM 푸시 토큰 등록 / 해제 ──────────────────────────────────
  Future<void> registerPushToken(String token) =>
      _dio.put(ApiPaths.myPushToken, data: {'pushToken': token});

  Future<void> clearPushToken() => _dio.delete(ApiPaths.myPushToken);

  // ── #14 보조: 카드 카테고리 목록 (소비패턴 입력의 categoryId 매핑용) ──
  /// GET /api/cards/categories → [{categoryId, categoryName, iconCode}, ...]
  Future<List<Map<String, dynamic>>> getCardCategories() async {
    final res = await _dio.get('/api/cards/categories');
    final raw = res.data['data'] as List? ?? const [];
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // ── #6 소비 패턴 조회 ───────────────────────────────────────────
  // 서버 계약: GET /api/users/me/spending
  //   응답 항목: { categoryId, categoryName, monthlyAmount, ratio }
  // 기존 코드는 존재하지 않는 categoryCode 를 읽어 기존 값이 항상 0으로 떴다.
  Future<List<Map<String, dynamic>>> getSpendingPatterns() async {
    final res = await _dio.get('/api/users/me/spending');
    final raw = res.data['data'];
    if (raw == null) return [];
    return (raw as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  // ── #6 소비 패턴 저장 ───────────────────────────────────────────
  // 서버 계약: PUT /api/users/me/spending
  //   body { patterns: [{ categoryId: int, monthlyAmount: int }] }
  // 기존 코드(POST /spending-patterns, {items}, categoryCode)는 전부 어긋나 저장 불가였다.
  // 반환값은 갱신된 건수(updatedCount).
  Future<int> saveSpendingPatterns(List<Map<String, dynamic>> patterns) async {
    final res =
    await _dio.put('/api/users/me/spending', data: {'patterns': patterns});
    return (res.data['data'] as num?)?.toInt() ?? 0;
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