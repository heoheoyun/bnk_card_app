import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:path_provider/path_provider.dart';

import '../config/app_config.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';

/// 모바일용 영속 쿠키 저장소.
///  - 로그인 시 받은 Set-Cookie 를 디스크에 저장 → 앱 재시작 후에도 세션 유지
///  - 웹에서는 브라우저가 쿠키를 직접 관리하므로 사용하지 않고,
///    로그인 여부는 LocalStorage 플래그로 대체한다.
class CookieStore {
  CookieStore._();

  static PersistCookieJar? _jar;

  static PersistCookieJar get jar {
    final j = _jar;
    if (j == null) {
      throw StateError('CookieStore.init() 을 main() 에서 먼저 await 해야 합니다.');
    }
    return j;
  }

  /// main() 에서 1회 호출. 웹에서는 no-op.
  static Future<void> init() async {
    if (kIsWeb || _jar != null) return;
    final dir = await getApplicationDocumentsDirectory();
    _jar = PersistCookieJar(
      ignoreExpires: false, // 만료 쿠키는 자동 폐기 → 세션 만료 자연 반영
      storage: FileStorage('${dir.path}/.cookies/'),
    );
  }

  static Future<bool> _has(String name, String path) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final cookies = await jar.loadForRequest(uri);
    return cookies.any((c) => c.name == name && c.value.isNotEmpty);
  }

  /// access_token 쿠키가 (미만료 상태로) 존재하는가
  static Future<bool> hasAccessToken() async {
    if (kIsWeb) return LocalStorage.getBool(StorageKeys.isLoggedIn) ?? false;
    return _has(AppConfig.accessTokenCookie, '/api/users/me');
  }

  /// refresh_token 쿠키가 존재하는가 (간편로그인 게이트 진입 판단용)
  static Future<bool> hasRefreshToken() async {
    if (kIsWeb) return LocalStorage.getBool(StorageKeys.isLoggedIn) ?? false;
    return _has(AppConfig.refreshTokenCookie, '/api/auth/refresh');
  }

  /// 로그아웃/세션 만료 시 전체 정리
  static Future<void> clear() async {
    await LocalStorage.remove(StorageKeys.isLoggedIn);
    if (kIsWeb) return;
    await jar.deleteAll();
  }
}