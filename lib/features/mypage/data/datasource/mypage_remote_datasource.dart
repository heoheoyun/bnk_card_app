import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';
import '../../../application/domain/entities/user_card.dart';
import '../models/trusted_device_model.dart';
import '../models/address_model.dart';

class MypageRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> getMyInfo() async {
    final res = await _dio.get(ApiPaths.myInfo);
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> updateMyInfo(Map<String, dynamic> data) =>
      _dio.put(ApiPaths.myInfo, data: data);

  // ── 주소 변경 → CI(연계정보) 갱신 (본인인증 결과 전송) ──────────────
  /// PATCH /api/users/me/ci
  /// body { name, residentFront, genderCode, address, addressDetail? }
  Future<void> updateCi(Map<String, dynamic> data) =>
      _dio.patch('${ApiPaths.myInfo}/ci', data: data);

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

  // ── 보유 카드 단건 상세 ─────────────────────────────────────────
  /// GET /api/users/me/cards/{userCardId}
  Future<UserCard> getUserCard(int userCardId) async {
    final res = await _dio.get('${ApiPaths.myCards}/$userCardId');
    return UserCard.fromJson(res.data['data'] as Map<String, dynamic>);
  }

  // ── 보유 카드 부분 수정 ─────────────────────────────────────────
  /// PATCH /api/users/me/cards/{userCardId}
  /// 변경 허용 필드만 [patch] 에 담아 전송 (한도/해외·비접촉/별칭/상태 등).
  Future<void> patchUserCard(int userCardId, Map<String, dynamic> patch) =>
      _dio.patch('${ApiPaths.myCards}/$userCardId', data: patch);

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

  // ── 신뢰 기기 관리 ─────────────────────────────────────────────
  /// GET /api/users/me/trusted-devices → 등록된 신뢰 기기 목록
  Future<List<TrustedDevice>> getTrustedDevices() async {
    final res = await _dio.get(ApiPaths.trustedDevices);
    final raw = res.data['data'] as List? ?? const [];
    return raw
        .map((e) => TrustedDevice.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// PATCH /api/users/me/trusted-devices/{deviceTrustId}  body { deviceName }
  Future<void> updateTrustedDeviceName(int deviceTrustId, String deviceName) =>
      _dio.patch(ApiPaths.trustedDevice(deviceTrustId), data: {'deviceName': deviceName});

  /// DELETE /api/users/me/trusted-devices/{deviceTrustId}
  Future<void> deleteTrustedDevice(int deviceTrustId) =>
      _dio.delete(ApiPaths.trustedDevice(deviceTrustId));

  // ── 주소록(배송지) 관리 ─────────────────────────────────────────
  /// GET /api/users/me/addresses
  Future<List<Address>> getAddresses() async {
    final res = await _dio.get(ApiPaths.addresses);
    final raw = res.data['data'] as List? ?? const [];
    return raw
        .map((e) => Address.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// POST /api/users/me/addresses
  Future<void> addAddress({
    String? alias,
    String? zipcode,
    required String address,
    String? addressDetail,
    bool setDefault = false,
  }) =>
      _dio.post(ApiPaths.addresses, data: {
        if (alias != null && alias.isNotEmpty) 'alias': alias,
        if (zipcode != null && zipcode.isNotEmpty) 'zipcode': zipcode,
        'address': address,
        if (addressDetail != null && addressDetail.isNotEmpty)
          'addressDetail': addressDetail,
        'setDefault': setDefault,
      });

  /// PATCH /api/users/me/addresses/{addressId}  body { alias }
  Future<void> updateAddressAlias(int addressId, String alias) =>
      _dio.patch(ApiPaths.address(addressId), data: {'alias': alias});

  /// PATCH /api/users/me/addresses/{addressId}/default
  Future<void> setDefaultAddress(int addressId) =>
      _dio.patch(ApiPaths.addressDefault(addressId));

  /// DELETE /api/users/me/addresses/{addressId}
  Future<void> deleteAddress(int addressId) =>
      _dio.delete(ApiPaths.address(addressId));

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