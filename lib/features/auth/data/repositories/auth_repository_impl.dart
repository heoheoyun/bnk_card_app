import '../../domain/repositories/auth_repository.dart';
import '../datasource/auth_remote_datasource.dart';
import '../models/login_request_model.dart';
import '../models/signup_request_model.dart';
import '../../../../core/constants/storage_keys.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/storage/local_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _ds;
  AuthRepositoryImpl(this._ds);

  @override Future<void> sendVerifyCode(String email)         => _ds.sendVerifyCode(email);
  @override Future<void> verifyEmail(String email, String code) => _ds.verifyEmail(email, code);

  @override Future<int> signup(String email, String password, String name, String phone) =>
      _ds.signup(SignupRequestModel(email: email, password: password, name: name, phone: phone));

  @override Future<void> login(String email, String password) async {
    await _ds.login(LoginRequestModel(email: email, password: password));
    await LocalStorage.setBool(StorageKeys.isLoggedIn, true);
  }

  @override Future<void> logout() async {
    await _ds.logout();
    await SecureStorage.deleteAll();
    await LocalStorage.remove(StorageKeys.isLoggedIn);
  }

  @override Future<void> refreshToken() => _ds.refresh();

  @override Future<Map<String, String>> findId(String name, String phone) async {
    final data = await _ds.findId(name, phone);
    return data.map((k, v) => MapEntry(k, v.toString()));
  }

  @override Future<void> findPassword(String email, String name) => _ds.findPassword(email, name);
  @override Future<void> resetPassword(String email, String token, String newPassword) =>
      _ds.resetPassword(email, token, newPassword);
}
