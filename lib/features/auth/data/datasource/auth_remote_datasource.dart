// 인증 원격 데이터소스 (쿠키 기반 + IP 2단계 인증).

import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/cookie_store.dart';
import '../models/login_request_model.dart';
import '../models/login_result.dart';
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

  /// 로그인 — 신뢰 IP면 쿠키 자동 저장(success), 미신뢰 IP면 IP 인증 필요(ipVerify).
  Future<LoginResult> login(LoginRequestModel req) async {
    final res = await _dio.post(ApiPaths.login, data: req.toJson());
    final data = res.data is Map ? res.data['data'] : null;

    if (data is Map && data['requireIpVerify'] == true) {
      return LoginResult.ipVerify(
        // 백엔드 login 응답에 userId 추가가 선행돼야 함
        userId: (data['userId'] as num).toInt(),
        challengeToken: data['challengeToken'] as String,
        availableMethods: (data['availableMethods'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
            const ['EMAIL'],
      );
    }
    return LoginResult.success();
  }

  /// IP 인증 — 이메일 코드 발송.
  Future<void> sendIpEmailCode({
    required int userId,
    required String challengeToken,
  }) =>
      _dio.post(ApiPaths.ipVerifyEmailSend, data: {
        'userId': userId,
        'challengeToken': challengeToken,
      });

  /// IP 인증 — 이메일 코드 확인. 성공 시 서버가 Set-Cookie 로 로그인 쿠키 발급.
  Future<void> confirmIpEmailCode({
    required int userId,
    required String challengeToken,
    required String code,
    String? nickname,
  }) =>
      _dio.post(ApiPaths.ipVerifyEmailConfirm, data: {
        'userId': userId,
        'challengeToken': challengeToken,
        'code': code,
        if (nickname != null) 'nickname': nickname,
      });

  /// IP 인증 — CI(이름+주민앞6+전화번호) 확인. 성공 시 서버가 Set-Cookie 로 로그인 쿠키 발급.
  Future<void> verifyIpCi({
    required int userId,
    required String challengeToken,
    required String name,
    required String residentFront,
    required String phone,
    String? nickname,
  }) =>
      _dio.post(ApiPaths.ipVerifyCi, data: {
        'userId': userId,
        'challengeToken': challengeToken,
        'name': name,
        'residentFront': residentFront,
        'phone': phone,
        if (nickname != null) 'nickname': nickname,
      });

  Future<void> logout() async {
    try {
      await _dio.post(ApiPaths.logout);
    } finally {
      await CookieStore.clear();
    }
  }

  Future<bool> refresh() async {
    try {
      await _dio.post(ApiPaths.refresh);
      return await CookieStore.hasAccessToken();
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
}