import 'package:dio/dio.dart';
import '../constants/api_paths.dart';
import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _isRefreshing = false;
  AuthInterceptor(this._dio);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.read(StorageKeys.accessToken);
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      _isRefreshing = true;
      try {
        final rt = await SecureStorage.read(StorageKeys.refreshToken);
        if (rt == null) throw Exception('no refresh token');
        final res = await _dio.post(ApiPaths.refresh,
            options: Options(headers: {'Cookie': 'refresh_token=$rt'}));
        final setCookie = res.headers['set-cookie']?.first ?? '';
        final match = RegExp(r'access_token=([^;]+)').firstMatch(setCookie);
        if (match != null) await SecureStorage.write(StorageKeys.accessToken, match.group(1)!);
        final opts = err.requestOptions;
        opts.headers['Authorization'] =
            'Bearer ${await SecureStorage.read(StorageKeys.accessToken)}';
        handler.resolve(await _dio.fetch(opts));
      } catch (_) {
        await SecureStorage.deleteAll();
        handler.next(err);
      } finally {
        _isRefreshing = false;
      }
    } else {
      handler.next(err);
    }
  }
}
