import 'dart:async';
import 'package:dio/dio.dart';
import '../constants/api_paths.dart';
import '../constants/storage_keys.dart';
import '../storage/secure_storage.dart';

/// 401 발생 시 access token 을 1회만 재발급(single-flight)하고,
/// 동시에 밀려든 요청들은 같은 refresh 의 결과를 공유한 뒤 각자 원요청을 재시도한다.
///
/// 기존 bool 플래그 방식의 문제:
///  - 동시에 401 이 여러 개 터지면 첫 요청만 refresh, 나머지는 그냥 에러로 떨어짐
///  - refresh 가 연달아 폭주하거나 후속 요청이 무더기로 실패
/// → Completer 로 묶어 "진행 중이면 그 결과를 await" 하도록 변경.
class AuthInterceptor extends Interceptor {
  final Dio _dio;
  AuthInterceptor(this._dio);

  /// 진행 중인 refresh 가 있으면 이 Completer 가 non-null.
  /// 성공 시 새 access token 문자열로 complete, 실패 시 completeError.
  Completer<String>? _refreshing;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await SecureStorage.read(StorageKeys.accessToken);
    if (token != null) options.headers['Authorization'] = 'Bearer $token';
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
      final newToken = await _ensureRefreshed();

      // 새 토큰으로 원요청 재시도
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      handler.resolve(await _dio.fetch(opts));
    } catch (_) {
      // refresh 실패 → 세션 정리 후 원에러 전달
      await SecureStorage.deleteAll();
      handler.next(err);
    }
  }

  /// 진행 중인 refresh 가 있으면 공유, 없으면 시작. 새 access token 반환.
  Future<String> _ensureRefreshed() {
    final inflight = _refreshing;
    if (inflight != null) return inflight.future;

    final completer = _refreshing = Completer<String>();
    _doRefresh().then((token) {
      completer.complete(token);
    }).catchError((e, st) {
      completer.completeError(e, st);
    }).whenComplete(() {
      _refreshing = null; // 다음 401 을 위해 해제
    });
    return completer.future;
  }

  /// 실제 refresh 호출 1회. 성공 시 새 access token 을 저장하고 반환.
  Future<String> _doRefresh() async {
    final rt = await SecureStorage.read(StorageKeys.refreshToken);
    if (rt == null) throw Exception('no refresh token');

    final res = await _dio.post(
      ApiPaths.refresh,
      options: Options(headers: {'Cookie': 'refresh_token=$rt'}),
    );

    final setCookie = res.headers['set-cookie']?.first ?? '';
    final match = RegExp(r'access_token=([^;]+)').firstMatch(setCookie);
    if (match == null) {
      throw Exception('refresh 응답에 access_token 이 없습니다.');
    }

    final newToken = match.group(1)!;
    await SecureStorage.write(StorageKeys.accessToken, newToken);
    return newToken;
  }
}