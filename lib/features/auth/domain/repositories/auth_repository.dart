abstract class AuthRepository {
  Future<void> sendVerifyCode(String email);
  Future<void> verifyEmail(String email, String code);
  Future<int>  signup(String email, String password, String name, String phone);
  Future<void> login(String email, String password);
  Future<void> logout();
  Future<void> refreshToken();
  Future<Map<String, String>> findId(String name, String phone);
  Future<void> findPassword(String email, String name);
  Future<void> resetPassword(String email, String token, String newPassword);
}
