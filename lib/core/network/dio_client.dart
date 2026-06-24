import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../config/app_config.dart';
import 'auth_interceptor.dart';
import 'cookie_store.dart';

class DioClient {
  DioClient._();
  static Dio? _instance;

  /// main() 에서 runApp 전에 반드시 await.
  static Future<void> init() async {
    await CookieStore.init();
    _instance ??= _build();
  }

  static Dio get instance {
    final i = _instance;
    if (i == null) {
      throw StateError('DioClient.init() 을 main() 에서 먼저 await 해야 합니다.');
    }
    return i;
  }

  static Dio _build() {
    final dio = Dio(BaseOptions(
      baseUrl:        AppConfig.baseUrl,
      connectTimeout: AppConfig.connectTimeout,
      receiveTimeout: AppConfig.receiveTimeout,
      contentType:    Headers.jsonContentType,
      extra: {'withCredentials': true}, // 웹: 브라우저가 쿠키 자동 전송
    ));

    // 모바일: 쿠키를 자동 첨부/저장 (웹은 브라우저가 처리하므로 미부착)
    if (!kIsWeb) {
      dio.interceptors.add(CookieManager(CookieStore.jar));
    }
    dio.interceptors.add(AuthInterceptor(dio));
    dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
    return dio;
  }
}