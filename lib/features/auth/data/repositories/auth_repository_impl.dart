import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/login_result.dart';
import '../models/signup_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _ds;
  AuthRepositoryImpl(this._ds);

  @override Future<void> sendVerifyCode(String email) => _ds.sendVerifyCode(email);
  @override Future<void> verifyEmail(String email, String code) => _ds.verifyEmail(email, code);
  @override Future<bool> verifyStatus(String email) => _ds.verifyStatus(email);

  @override Future<int> signup(SignupRequestModel req) => _ds.signup(req);

  // 로그인 상태 플래그는 실제 쿠키 발급 시점(onLogin)에서 설정한다.
  @override Future<LoginResult> login(String email, String password) =>
      _ds.login(LoginRequestModel(email: email, password: password));

  @override Future<void> logout() => _ds.logout();

  @override Future<void> refreshToken() => _ds.refresh();

  @override Future<Map<String, String>> findId(String name, String phone) async {
    final data = await _ds.findId(name, phone);
    return data.map((k, v) => MapEntry(k, v.toString()));
  }

  @override Future<void> findPassword(String email, String name) => _ds.findPassword(email, name);
  @override Future<void> resetPassword(String email, String token, String newPassword) =>
      _ds.resetPassword(email, token, newPassword);

  @override Future<void> sendDeviceEmailCode({
    required String challengeToken,
  }) =>
      _ds.sendDeviceEmailCode(challengeToken: challengeToken);

  @override Future<void> confirmDeviceEmailCode({
    required String challengeToken,
    required String code,
    String? deviceName,
  }) =>
      _ds.confirmDeviceEmailCode(
          challengeToken: challengeToken, code: code, deviceName: deviceName);

  @override Future<void> verifyDeviceCi({
    required String challengeToken,
    required String name,
    required String residentFront,
    required String phone,
    String? deviceName,
  }) =>
      _ds.verifyDeviceCi(
          challengeToken: challengeToken,
          name: name, residentFront: residentFront, phone: phone, deviceName: deviceName);
}