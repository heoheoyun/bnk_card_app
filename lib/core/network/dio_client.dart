import 'package:dio/dio.dart';
import '../config/app_config.dart';
import 'auth_interceptor.dart';

class DioClient {
  DioClient._();
  static Dio? _instance;
  static Dio get instance => _instance ??= _build();

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl:        AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      contentType:    Headers.jsonContentType,
    ));
    dio.interceptors.addAll([
      AuthInterceptor(dio),
      LogInterceptor(requestBody: true, responseBody: true),
    ]);
    return dio;
  }
}
