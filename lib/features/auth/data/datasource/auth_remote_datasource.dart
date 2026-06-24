//  - login()  : 응답 Set-Cookie 헤더에서 access_token / refresh_token 을 추출해
//               SecureStorage 에 저장한다. (모바일은 쿠키 자동 보관이 없으므로 필수)
//  - logout() : 서버 호출 후 로컬 토큰을 명시적으로 삭제한다.
//  - refresh(): 재발급된 access_token 을 SecureStorage 에 갱신 저장한다.
//
// 이렇게 해야 AuthInterceptor.onRequest 의 `Authorization: Bearer <token>` 가
// 정상 동작하고, 앱 재시작 시 authStateProvider._init() 가 세션을 복원할 수 있다.

import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/login_request_model.dart';
import '../models/signup_request_model.dart';

class AuthRemoteDatasource {
  final Dio _dio = DioClient.instance;

  Future<void> sendVerifyCode(String email) =>
      _dio.post(ApiPaths.sendVerifyCode, data: {'email': email});

  Future<void> verifyEmail(String email, String code) =>
      _dio.post(ApiPaths.verifyEmail, data: {'email': email, 'code': code});

  Future<int> signup(SignupRequestModel req) async {
    final res = await _dio.post(ApiPaths.signup, data: req.toJson());
    return res.data['data'] as int;
  }

  /// 로그인 — 성공 시 Set-Cookie 의 토큰을 SecureStorage 에 저장.
  Future<void> login(LoginRequestModel req) async {
    final res = await _dio.post(ApiPaths.login, data: req.toJson());
    await _persistTokensFromResponse(res);
  }

  /// 로그아웃 — 서버 세션 revoke 후 로컬 토큰 제거.
  Future<void> logout() async {
    try {
      await _dio.post(ApiPaths.logout);
    } finally {
      // 서버 호출이 실패하더라도 단말의 토큰은 반드시 정리한다.
      await SecureStorage.delete(StorageKeys.accessToken);
      await SecureStorage.delete(StorageKeys.refreshToken);
    }
  }

  /// 토큰 재발급 — refresh_token 쿠키를 직접 실어 보내고 새 access_token 저장.
  /// (AuthInterceptor 와 별개로 명시적 호출이 필요한 경우 사용: 예) 간편로그인 게이트 통과 직후)
  Future<bool> refresh() async {
    final rt = await SecureStorage.read(StorageKeys.refreshToken);
    if (rt == null || rt.isEmpty) return false;
    try {
      final res = await _dio.post(
        ApiPaths.refresh,
        options: Options(headers: {'Cookie': 'refresh_token=$rt'}),
      );
      return _persistTokensFromResponse(res);
    } on DioException {
      return false;
    }
  }

  Future<Map<String, dynamic>> findId(String name, String phone) async {
    final res =
        await _dio.post(ApiPaths.findId, data: {'name': name, 'phone': phone});
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> findPassword(String email, String name) =>
      _dio.post(ApiPaths.findPassword, data: {'email': email, 'name': name});

  Future<void> resetPassword(String email, String token, String newPassword) =>
      _dio.post(ApiPaths.resetPassword,
          data: {'email': email, 'token': token, 'newPassword': newPassword});

  // ── 내부 헬퍼 ────────────────────────────────────────────────────────

  /// 응답의 set-cookie 헤더들에서 access_token / refresh_token 을 파싱해 저장.
  /// 하나라도 저장되면 true.
  Future<bool> _persistTokensFromResponse(Response res) async {
    final cookies = res.headers['set-cookie'] ?? const <String>[];
    bool wrote = false;

    final access = _extractCookie(cookies, 'access_token');
    if (access != null) {
      await SecureStorage.write(StorageKeys.accessToken, access);
      wrote = true;
    }
    final refresh = _extractCookie(cookies, 'refresh_token');
    if (refresh != null) {
      await SecureStorage.write(StorageKeys.refreshToken, refresh);
      wrote = true;
    }
    return wrote;
  }

  /// 여러 Set-Cookie 라인에서 특정 쿠키 값을 추출. 빈 값(삭제용 Max-Age=0)은 무시.
  String? _extractCookie(List<String> setCookieLines, String name) {
    for (final line in setCookieLines) {
      final m = RegExp('$name=([^;]*)').firstMatch(line);
      if (m != null) {
        final v = m.group(1) ?? '';
        if (v.isNotEmpty) return v;
      }
    }
    return null;
  }
}
