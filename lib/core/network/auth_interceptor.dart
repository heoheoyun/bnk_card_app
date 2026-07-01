import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_paths.dart';
import '../storage/secure_storage.dart';

/// 401 발생 시 access token 을 1회만 재발급(single-flight)하고,
/// 동시에 밀려든 요청들은 같은 refresh 의 결과를 공유한 뒤 각자 원요청을 재시도한다.
///
/// 기존 bool 플래그 방식의 문제:
///  - 동시에 401 이 여러 개 터지면 첫 요청만 refresh, 나머지는 그냥 에러로 떨어짐
///  - refresh 가 연달아 폭주하거나 후속 요청이 무더기로 실패
/// → Completer 로 묶어 "진행 중이면 그 결과를 await" 하도록 변경.
///
/// 인증은 전부 쿠키(access_token/refresh_token) 기반이라 CookieManager 가
/// 요청마다 자동으로 첨부/저장한다. refresh 도 SecureStorage 가 아니라
/// 쿠키에 실린 refresh_token 으로 서버가 판단하므로, 여기서는 그냥
/// /api/auth/refresh 를 호출해 새 Set-Cookie 를 받기만 하면 된다.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  AuthInterceptor(this._dio);

  /// 진행 중인 refresh 가 있으면 이 Completer 가 non-null.
  Completer<void>? _refreshing;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // ngrok 브라우저 경고 창 건너뛰기 헤더 추가
    options.headers['ngrok-skip-browser-warning'] = 'true';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;

    // refresh 엔드포인트 자체가 401 이면 재귀 방지 → 그대로 로그아웃 처리
    final isRefreshCall =
    err.requestOptions.path.contains(ApiPaths.refresh);

    if (status != 401 || isRefreshCall) {
      handler.next(err);
      return;
    }

    try {
      // single-flight: 진행 중인 refresh 가 있으면 그 결과를 기다리고,
      // 없으면 내가 새로 시작한다.
      await _ensureRefreshed();

      // 갱신된 쿠키로 원요청 재시도 (CookieManager 가 자동 첨부)
      handler.resolve(await _dio.fetch(err.requestOptions));
    } catch (_) {
      // refresh 실패 → 세션(쿠키/토큰)만 정리하고 간편로그인 설정은 보존.
      // (간편로그인 PIN/패턴/생체 설정은 access token 재발급 실패와 무관하다)
      await SecureStorage.deleteSessionOnly();
      handler.next(err);
    }
  }

  /// 진행 중인 refresh 가 있으면 공유, 없으면 시작.
  Future<void> _ensureRefreshed() {
    final inflight = _refreshing;
    if (inflight != null) return inflight.future;

    final completer = _refreshing = Completer<void>();
    _doRefresh().then((_) {
      completer.complete();
    }).catchError((e, st) {
      completer.completeError(e, st);
    }).whenComplete(() {
      _refreshing = null; // 다음 401 을 위해 해제
    });
    return completer.future;
  }

  /// 실제 refresh 호출 1회. refresh_token 쿠키는 CookieManager 가 자동으로
  /// 실어 보내고, 응답의 Set-Cookie(access_token) 도 자동으로 저장된다.
  Future<void> _doRefresh() => _dio.post(ApiPaths.refresh);
}
