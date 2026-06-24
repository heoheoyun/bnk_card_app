import 'package:go_router/go_router.dart';

/// GoRouter redirect 로직 — 인증 상태에 따른 경로 보호.
///
/// [_publicRoutes]  : 비로그인 허용 (정확 일치)
/// [_isPublic()]    : prefix 기반 동적 공개 경로 포함
/// 그 외 모든 경로  : 로그인 필수 (인증 보호)
class RouteGuards {
  RouteGuards._();

  /// 비로그인에서도 접근 가능한 정확 경로 목록
  static const _publicRoutes = {
    '/',
    '/login',
    '/ip-verify',
    '/signup',
    '/signup/verify',
    '/find-id',
    '/reset-password',
    '/search',
    '/ai/chat',
    '/unlock',
  };

  /// 로그인 상태에서 접근 시 홈으로 리다이렉트할 경로
  static const _authOnlyRoutes = {
    '/login',
    '/signup',
    '/signup/verify',
  };

  static bool _isPublic(String location) =>
      _publicRoutes.contains(location) ||
          location.startsWith('/cards') ||   // 카드 목록·상세·비교 — 비회원 허용
          location.startsWith('/terms');     // 약관 — 비회원 허용
  // ↑ /mypage, /spending/input 은 의도적으로 제외 → 인증 필수

  /// [isLoggedIn] 은 [authStateProvider] 의 현재 값
  static String? redirect(bool isLoggedIn, GoRouterState state) {
    final loc = state.matchedLocation;

    // 로그인 상태에서 인증 전용 페이지 접근 → 홈으로
    if (isLoggedIn && _authOnlyRoutes.contains(loc)) {
      return '/';
    }

    // 비로그인 + 보호 경로 → 로그인 페이지로
    if (!isLoggedIn && !_isPublic(loc)) {
      return '/login';
    }

    return null; // 리다이렉트 없음
  }
}