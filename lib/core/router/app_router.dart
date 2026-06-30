import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_state_provider.dart';
import '../providers/router_notifier.dart';
import 'route_guards.dart';
import '../../features/auth/presentation/pages/ip_verify_page.dart';

// ── Splash ───────────────────────────────────────────────────────
import '../../features/splash/presentation/pages/splash_page.dart';

// ── Auth ──────────────────────────────────────────────────────────
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/signup_verify_page.dart';
import '../../features/auth/presentation/pages/find_id_page.dart';
import '../../features/auth/presentation/pages/reset_password_page.dart';
import '../../features/quick_login/presentation/pages/quick_login_gate_page.dart';
import '../../features/mypage/presentation/pages/quick_login_settings_page.dart';

// Notification

import '../../features/notification/presentation/pages/notification_page.dart';


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
import '../../features/mypage/presentation/pages/my_card_detail_page.dart';
import '../../features/mypage/presentation/pages/address_ci_verify_page.dart';
import '../../features/mypage/presentation/pages/spending_input_page.dart';
import '../../features/mypage/presentation/pages/trusted_ips_page.dart';

// ── Account ───────────────────────────────────────────────────────
import '../../features/application/presentation/pages/account_create_page.dart';
import '../../features/application/presentation/pages/my_accounts_page.dart';

// ── Application (신용) ───────────────────────────────────────────
import '../../features/application/presentation/pages/credit/credit_reviewing_page.dart';
import '../../features/application/presentation/pages/credit/credit_step1_terms_page.dart';
import '../../features/application/presentation/pages/credit/credit_step2_identity_page.dart';
import '../../features/application/presentation/pages/credit/credit_step3_applicant_page.dart';
import '../../features/application/presentation/pages/credit/credit_step4_payment_page.dart';
import '../../features/application/presentation/pages/credit/credit_step5_documents_page.dart';
import '../../features/application/presentation/pages/credit/credit_result_page.dart';

// ── Application (체크) ───────────────────────────────────────────
import '../../features/application/presentation/pages/check/check_step1_terms_page.dart';
import '../../features/application/presentation/pages/check/check_step2_identity_page.dart';
import '../../features/application/presentation/pages/check/check_step3_applicant_page.dart';
import '../../features/application/presentation/pages/check/check_step4_payment_page.dart';
import '../../features/application/presentation/pages/check/check_result_page.dart';

  final appRouterProvider = Provider<GoRouter>((ref) {
  // 라우터는 앱 생애 동안 단 한 번만 생성한다.
  // authStateProvider 를 watch 하면 로그인 상태가 바뀔 때마다 GoRouter 자체가
  // 재생성되어 initialLocation('/splash')로 튕긴다(→ 간편로그인 후 /splash → /unlock
  // 재진입 = 로그인 2회 버그). 상태 변화는 refreshListenable 로만 반영하고,
  // 현재 로그인값은 redirect 시점에 ref.read 로 즉시 읽는다.
  final notifier   = ref.watch(routerNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (ctx, state) {
      // 스플래시는 리다이렉트 제외
      if (state.matchedLocation == '/splash') return null;
      final isLoggedIn = ref.read(authStateProvider);
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
      GoRoute(
        path: '/unlock',
        builder: (_, __) => const QuickLoginGatePage(),
      ),
      GoRoute(
        path: '/mypage/quick-login',
        builder: (_, state) => QuickLoginSettingsPage(
          onboarding: state.uri.queryParameters['onboarding'] == '1',
        ),
      ),

      // ── 알림 ───────────────────────────────────────────────────
      GoRoute(
        path: '/notifications',
        builder: (_, __) => const NotificationPage(),
      ),
      // -- 계좌
      GoRoute(
        path: '/mypage/accounts',
        builder: (_, __) => const MyAccountsPage(),
      ),
      GoRoute(
        path: '/accounts/create',
        builder: (_, __) => const AccountCreatePage(),
      ),
      // ── 카드 ───────────────────────────────────────────────────
      // /cards/compare 를 /cards/:id 보다 먼저 선언해야 충돌 없음
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

      // ── 보유 카드 관리 (USER_CARDS 컬럼 기반) ──────────────────
      GoRoute(
        path: '/mypage/cards/:id',
        builder: (_, state) => MyCardDetailPage(
          userCardId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),

      // ── 주소 변경 · CI 갱신 (본인인증) ─────────────────────────
      GoRoute(
        path: '/mypage/address-verify',
        builder: (_, __) => const AddressCiVerifyPage(),
      ),

      // ── 신뢰 기기(IP) 관리 ─────────────────────────────────────
      GoRoute(
        path: '/mypage/trusted-ips',
        builder: (_, __) => const TrustedIpsPage(),
      ),

      // ── 소비 패턴 ──────────────────────────────────────────────
      GoRoute(
        path: '/spending/input',
        builder: (_, __) => const SpendingInputPage(),
      ),

      // ── 카드 발급 (신용) ───────────────────────────────────────────
      GoRoute(
        path: '/application/credit/step1',
        builder: (context, state) => CreditStep1TermsPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/credit/step2',
        builder: (context, state) => CreditStep2IdentityPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/credit/step3',
        builder: (context, state) => CreditStep3ApplicantPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/credit/step4',
        builder: (context, state) => CreditStep4PaymentPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/credit/step5',
        builder: (context, state) => CreditStep5DocumentsPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/credit/result',
        builder: (context, state) => CreditResultPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/credit/:id/documents',
        builder: (context, state) => CreditReviewingPage(
          creditAppId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),

// ── 카드 발급 (체크) ───────────────────────────────────────────
      GoRoute(
        path: '/application/check/step1',
        builder: (context, state) => CheckStep1TermsPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/check/step2',
        builder: (context, state) => CheckStep2IdentityPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/check/step3',
        builder: (context, state) => CheckStep3ApplicantPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/check/step4',
        builder: (context, state) => CheckStep4PaymentPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/application/check/result',
        builder: (context, state) => CheckResultPage(
          cardId: state.extra as int,
        ),
      ),
      GoRoute(
        path: '/ip-verify',
        builder: (_, state) => IpVerifyPage(args: state.extra as IpVerifyArgs),
      ),
    ],
  );
});