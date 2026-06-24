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

  // IP 2단계 인증
  Future<void> sendIpEmailCode({
    required int userId,
    required String challengeToken,
  });
  Future<void> confirmIpEmailCode({
    required int userId,
    required String challengeToken,
    required String code,
    String? nickname,
  });
}