import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';
import '../push/push_service.dart';
import 'dart:convert';
import '../network/cookie_store.dart';
import '../../features/quick_login/data/quick_login_service.dart';

/// 앱 전역 로그인 상태 Notifier.
///
/// - 앱 시작: SecureStorage 에서 accessToken 존재 여부로 상태 복원
/// - 로그인 성공: [onLogin] 호출 → state = true + FCM 토큰 등록
/// - 로그아웃 / 토큰 만료: [onLogout] 호출 → FCM 토큰 해제 + 토큰 삭제 + state = false
///
/// GoRouter [RouterNotifier] 가 이 상태를 구독하여
/// 상태 변경 시 redirect 를 자동 재평가한다.
class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    // 토큰은 쿠키(PersistCookieJar)에 저장되므로 쿠키 존재로 세션 복원
    state = await CookieStore.hasRefreshToken();
  }

  /// 로그인 성공 후 호출
  Future<void> onLogin() async {
    state = true;
    // FCM 토큰을 서버에 등록 (실패해도 로그인 흐름에 영향 없음)
    await PushService.instance.registerToken();
  }

  /// 로그아웃 혹은 강제 만료 후 호출
  Future<void> onLogout() async {
    await PushService.instance.unregister();
    await CookieStore.clear();                    // 실제 토큰(쿠키) 삭제
    await QuickLoginService.instance.clearAll();  // 간편로그인 해제
    await SecureStorage.deleteAll();
    await LocalStorage.remove(StorageKeys.isLoggedIn);
    state = false;
  }
}

final authStateProvider =
StateNotifierProvider<AuthStateNotifier, bool>(
      (_) => AuthStateNotifier(),
);

bool _isJwtExpired(String jwt) {
  try {
    final parts = jwt.split('.');
    if (parts.length != 3) return true;
    final payload = json.decode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    ) as Map<String, dynamic>;
    final exp = payload['exp'];
    if (exp is! int) return false;                 // exp 없으면 만료 판단 보류
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry);
  } catch (_) {
    return true;                                    // 파싱 실패 → 안전하게 만료 취급
  }
}