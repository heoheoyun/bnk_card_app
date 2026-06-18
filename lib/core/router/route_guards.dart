import 'package:go_router/go_router.dart';

class RouteGuards {
  RouteGuards._();

  static const _publicRoutes = {
    '/',
    '/login',
    '/signup',
    '/signup/verify',
    '/find-id',
    '/reset-password',
    '/search',
    '/ai/chat',
  };

  static bool _isPublic(String location) =>
      _publicRoutes.contains(location) ||
          location.startsWith('/cards') ||
          location.startsWith('/terms');

  /// [isLoggedIn] 은 [authStateProvider] 의 현재 값
  static String? redirect(bool isLoggedIn, GoRouterState state) {
    final loc = state.matchedLocation;

    // 로그인 상태에서 인증 페이지 접근 → 홈
    if (isLoggedIn &&
        (loc == '/login' ||
            loc == '/signup' ||
            loc == '/signup/verify')) {
      return '/';
    }

    // 비로그인 + 보호 경로 → 로그인
    if (!isLoggedIn && !_isPublic(loc)) {
      return '/login';
    }

    return null;
  }
}