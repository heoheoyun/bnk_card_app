import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';
import '../providers/router_notifier.dart';
import 'route_guards.dart';

// ── Splash ───────────────────────────────────────────────────────
import '../../features/splash/presentation/pages/splash_page.dart';

// ── Auth ──────────────────────────────────────────────────────────
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/signup_verify_page.dart';
import '../../features/auth/presentation/pages/find_id_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';

// ── Home ─────────────────────────────────────────────────────────
import '../../features/home/presentation/pages/home_page.dart';

// ── Card ─────────────────────────────────────────────────────────
import '../../features/card/presentation/pages/card_detail_page.dart';
import '../../features/card/presentation/pages/card_compare_page.dart';

// ── Search ───────────────────────────────────────────────────────
import '../../features/search/presentation/pages/search_page.dart';

// ── AI ───────────────────────────────────────────────────────────
import '../../features/ai/presentation/pages/ai_chat_page.dart';

// ── Terms ────────────────────────────────────────────────────────
import '../../features/terms/presentation/pages/terms_page.dart';

// ── MyPage ───────────────────────────────────────────────────────
import '../../features/mypage/presentation/pages/mypage_page.dart';
import '../../features/mypage/presentation/pages/spending_input_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier   = ref.watch(routerNotifierProvider.notifier);
  final isLoggedIn = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (ctx, state) {
      // 스플래시는 리다이렉트 제외
      if (state.matchedLocation == '/splash') return null;
      return RouteGuards.redirect(isLoggedIn, state);
    },
    routes: [
      // ── 스플래시 ────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        builder: (_, __) => const SplashPage(),
      ),

      // ── 홈 ─────────────────────────────────────────────────────
      GoRoute(
        path: '/',
        builder: (_, __) => const HomePage(),
      ),

      // ── 인증 ───────────────────────────────────────────────────
      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (_, __) => const SignupPage(),
      ),
      GoRoute(
        path: '/signup/verify',
        builder: (_, __) => const SignupVerifyPage(),
      ),
      GoRoute(
        path: '/find-id',
        builder: (_, __) => const FindIdPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (_, __) => const ResetPasswordPage(),
      ),

      // ── 카드 ───────────────────────────────────────────────────
      GoRoute(
        path: '/cards/compare',
        builder: (_, __) => const CardComparePage(),
      ),
      GoRoute(
        path: '/cards/:id',
        builder: (_, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return CardDetailPage(cardId: id);
        },
      ),

      // ── 검색 ───────────────────────────────────────────────────
      GoRoute(
        path: '/search',
        builder: (_, state) {
          final q = state.uri.queryParameters['q'];
          return SearchPage(initialQuery: q);
        },
      ),

      // ── AI 챗봇 ────────────────────────────────────────────────
      GoRoute(
        path: '/ai/chat',
        builder: (_, __) => const AiChatPage(),
      ),

      // ── 약관 ───────────────────────────────────────────────────
      GoRoute(
        path: '/terms/:type',
        builder: (_, state) {
          final type = state.pathParameters['type'] ?? 'SIGNUP';
          return TermsPage(packageType: type);
        },
      ),

      // ── 마이페이지 ─────────────────────────────────────────────
      GoRoute(
        path: '/mypage',
        builder: (_, __) => const MyPagePage(),
      ),

      // ── 소비 패턴 ──────────────────────────────────────────────
      GoRoute(
        path: '/spending/input',
        builder: (_, __) => const SpendingInputPage(),
      ),
    ],
  );
});