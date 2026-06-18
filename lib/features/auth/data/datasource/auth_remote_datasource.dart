import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';
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

  Future<void> login(LoginRequestModel req) =>
      _dio.post(ApiPaths.login, data: req.toJson());

  Future<void> logout() => _dio.post(ApiPaths.logout);

  Future<void> refresh() => _dio.post(ApiPaths.refresh);

  Future<Map<String, dynamic>> findId(String name, String phone) async {
    final res = await _dio.post(ApiPaths.findId, data: {'name': name, 'phone': phone});
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<void> findPassword(String email, String name) =>
      _dio.post(ApiPaths.findPassword, data: {'email': email, 'name': name});

  Future<void> resetPassword(String email, String token, String newPassword) =>
      _dio.post(ApiPaths.resetPassword, data: {'email': email, 'token': token, 'newPassword': newPassword});
}
