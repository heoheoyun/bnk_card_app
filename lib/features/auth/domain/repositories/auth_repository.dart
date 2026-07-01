import '../../data/models/login_result.dart';
import '../../data/models/signup_request_model.dart';

abstract class AuthRepository {
  Future<void> sendVerifyCode(String email);
  Future<void> verifyEmail(String email, String code);
  Future<int> signup(SignupRequestModel req);

  Future<LoginResult> login(String email, String password);
  Future<void> logout();
  Future<void> refreshToken();

  Future<Map<String, String>> findId(String name, String phone);
  Future<void> findPassword(String email, String name);
  Future<void> resetPassword(String email, String token, String newPassword);

  // 새 기기 인증 (challengeToken 은 서버가 발급한 불투명 토큰, userId는 서버가 도출)
  Future<void> sendDeviceEmailCode({
    required String challengeToken,
  });
  Future<void> confirmDeviceEmailCode({
    required String challengeToken,
    required String code,
    String? deviceName,
  });
  Future<void> verifyDeviceCi({
    required String challengeToken,
    required String name,
    required String residentFront,
    required String phone,
    String? deviceName,
  });
}