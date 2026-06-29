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
/// - 앱 시작: 항상 false 로 시작한다. 실제 세션 유효성은 SplashPage 가
///   서버(refresh) 검증 후 onLogin()/onLogout() 으로 확정한다.
///   (로컬 쿠키만 보고 true 로 만들던 기존 로직이 #3 '정보 없는 회원' 버그의 원인)
/// - 로그인 성공: [onLogin] 호출 → state = true + FCM 토큰 등록
/// - 로그아웃 / 토큰 만료: [onLogout] 호출 → FCM 해제 + 쿠키/간편로그인/시큐어스토리지 정리 + state = false
///
/// GoRouter [RouterNotifier] 가 이 상태를 구독하여 상태 변경 시 redirect 를 재평가한다.
class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    // 콜드 스타트 시점엔 항상 false.
    // 쿠키가 디스크에 있어도 서버 세션이 살아있다는 보장이 없으므로(서버 재시작/세션 revoke),
    // SplashPage 가 /api/auth/refresh 로 서버 진실을 확인한 뒤 상태를 확정한다.
    state = false;
  }

  /// 로그인 성공(또는 스플래시에서 세션 검증 성공) 후 호출
  Future<void> onLogin() async {
    state = true;
    // FCM 토큰을 서버에 등록 (실패해도 로그인 흐름에 영향 없음)
    await PushService.instance.registerToken();
  }

  /// 로그아웃 혹은 강제 만료 후 호출.
  ///
  /// [keepQuickLogin] true(기본값): 쿠키 + 세션 시큐어스토리지만 정리하고
  /// 간편로그인(PIN/패턴/생체) 설정은 보존한다.
  /// false: 간편로그인 설정까지 모두 해제한다(완전 로그아웃, 다른 계정 전환 등).
  Future<void> onLogout({bool keepQuickLogin = true}) async {
    await PushService.instance.unregister();
    if (keepQuickLogin) {
      await CookieStore.clear();                  // 실제 토큰(쿠키) 삭제
      await SecureStorage.deleteSessionOnly();     // 간편로그인 키는 보존
    } else {
      await QuickLoginService.instance.clearAll(); // 간편로그인 해제
      await SecureStorage.deleteAll();
    }
    await LocalStorage.remove(StorageKeys.isLoggedIn);
    state = false;
  }

  /// 앱 종료 시 호출. 쿠키 / 간편로그인 / 서버세션은 모두 보존하고
  /// 메모리 상의 로그인 상태만 false 로 내려서 다음 콜드스타트에
  /// SplashPage 가 서버 검증부터 다시 시작하도록 한다.
  void resetSessionForExit() {
    state = false;
  }
}

final authStateProvider =
StateNotifierProvider<AuthStateNotifier, bool>(
      (_) => AuthStateNotifier(),
);

/// JWT 만료 여부 판정 유틸 (필요 시 사용).
bool isJwtExpired(String jwt) {
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