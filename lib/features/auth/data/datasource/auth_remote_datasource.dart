// 인증 원격 데이터소스 (쿠키 기반 + 새 기기 인증).

import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/device/device_id_service.dart';
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

  /// 매직링크(원터치) 인증 완료 여부 조회 — 가입 화면 폴링용.
  Future<bool> verifyStatus(String email) async {
    final res = await _dio.get(ApiPaths.verifyStatus,
        queryParameters: {'email': email});
    final data = res.data is Map ? res.data['data'] : null;
    return data is Map && data['verified'] == true;
  }

  Future<int> signup(SignupRequestModel req) async {
    // 가입 기기를 최초 신뢰 기기로 등록하기 위해 기기 컨텍스트를 함께 전송한다.
    final dev = await DeviceIdService.instance.current();
    final data = {
      ...req.toJson(),
      'deviceId': dev.id,
      'deviceName': dev.name,
      'platform': dev.platform,
    };
    final res = await _dio.post(ApiPaths.signup, data: data);
    return res.data['data'] as int;
  }

  /// 로그인 — 신뢰 기기면 쿠키 자동 저장(success), 미신뢰 기기면 새 기기 인증 필요(deviceVerify).
  Future<LoginResult> login(LoginRequestModel req) async {
    // 신뢰 기기 판정용 기기 컨텍스트를 요청에 실어 보낸다.
    final dev = await DeviceIdService.instance.current();
    final payload = LoginRequestModel(
      email: req.email,
      password: req.password,
      deviceId: dev.id,
      deviceName: dev.name,
      platform: dev.platform,
    );

    final res = await _dio.post(ApiPaths.login, data: payload.toJson());
    final data = res.data is Map ? res.data['data'] : null;

    if (data is Map && data['requireDeviceVerify'] == true) {
      return LoginResult.deviceVerify(
        challengeToken: data['challengeToken'] as String,
        availableMethods: (data['availableMethods'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const ['EMAIL'],
      );
    }
    return LoginResult.success();
  }

  /// 새 기기 인증 — 이메일 코드 발송.
  Future<void> sendDeviceEmailCode({required String challengeToken}) =>
      _dio.post(ApiPaths.deviceVerifyEmailSend, data: {
        'challengeToken': challengeToken,
      });

  /// 새 기기 인증 — 이메일 코드 확인. 성공 시 서버가 Set-Cookie 로 로그인 쿠키 발급.
  Future<void> confirmDeviceEmailCode({
    required String challengeToken,
    required String code,
    String? deviceName,
  }) =>
      _dio.post(ApiPaths.deviceVerifyEmailConfirm, data: {
        'challengeToken': challengeToken,
        'code': code,
        if (deviceName != null) 'deviceName': deviceName,
      });

  /// 새 기기 인증 — CI(이름+주민앞6+전화번호) 확인. 성공 시 서버가 Set-Cookie 로 로그인 쿠키 발급.
  Future<void> verifyDeviceCi({
    required String challengeToken,
    required String name,
    required String residentFront,
    required String phone,
    String? deviceName,
  }) =>
      _dio.post(ApiPaths.deviceVerifyCi, data: {
        'challengeToken': challengeToken,
        'name': name,
        'residentFront': residentFront,
        'phone': phone,
        if (deviceName != null) 'deviceName': deviceName,
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
