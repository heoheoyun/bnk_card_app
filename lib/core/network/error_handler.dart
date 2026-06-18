import 'package:dio/dio.dart';
import '../error/app_exception.dart';

class ErrorHandler {
  ErrorHandler._();

  /// DioException → AppException 변환
  static AppException handle(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return AppException.timeout();
      case DioExceptionType.connectionError:
        return AppException.network();
      case DioExceptionType.badResponse:
        final status = e.response?.statusCode ?? 0;
        final data   = e.response?.data as Map<String, dynamic>?;
        final code   = data?['code']    as String? ?? 'UNKNOWN';
        final msg    = data?['message'] as String? ?? '서버 오류가 발생했습니다.';
        if (status == 401) return AppException.unauthorized();
        return AppException.fromResponse(status, code, msg);
      default:
        return AppException.unknown();
    }
  }
}
