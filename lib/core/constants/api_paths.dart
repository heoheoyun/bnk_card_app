class ApiPaths {
  ApiPaths._();

  // ── 인증 ────────────────────────────────────────────────────────
  static const String sendVerifyCode  = '/api/auth/send-verify-code';
  static const String verifyEmail     = '/api/auth/verify-email';
  static const String signup          = '/api/auth/signup';
  static const String login           = '/api/auth/login';
  static const String logout          = '/api/auth/logout';
  static const String refresh         = '/api/auth/refresh';
  static const String findId          = '/api/auth/find-id';
  static const String findPassword    = '/api/auth/find-password';
  static const String resetPassword   = '/api/auth/reset-password';

  // ── 홈 ──────────────────────────────────────────────────────────
  static const String homeBanners     = '/api/home/banners';

  // ── 카드 ────────────────────────────────────────────────────────
  static const String cards           = '/api/cards';
  static const String cardsTop3       = '/api/cards/top3';
  static const String cardCategories  = '/api/cards/categories';
  static const String cardCompare     = '/api/cards/compare';

  // ── 검색 ────────────────────────────────────────────────────────
  static const String search           = '/api/search';
  static const String suggestKeywords  = '/api/search/keywords/suggest';
  static const String popularKeywords  = '/api/search/keywords/popular';

  // ── AI 챗봇 ──────────────────────────────────────────────────────
  static const String chat        = '/api/chat';
  static const String chatHistory = '/api/chat/history';

  // ── 마이페이지 ───────────────────────────────────────────────────
  static const String myInfo             = '/api/users/me';
  static const String myPassword         = '/api/users/me/password';
  static const String myCards            = '/api/users/me/cards';
  /// FCM 디바이스 푸시 토큰 등록(PUT) / 해제(DELETE)
  static const String myPushToken        = '/api/users/me/push-token';
  /// [deprecated] 단순 조회용으로만 사용하던 구 경로 — 하위 호환 유지
  static const String mySpending         = '/api/users/me/spending';
  /// 소비 패턴 조회·저장 (GET / POST)
  static const String mySpendingPatterns = '/api/users/me/spending-patterns';
  /// 월별 카드별 실제 결제 집계 (GET ?year=&month=)
  static const String myMonthlySpending = '/api/users/me/monthly-spending';

  // ── 알림 ─────────────────────────────────────────────────────────
  /// 내 알림 목록 + 미읽음수 (GET)
  static const String notifications            = '/api/notifications';
  /// 미읽음 수만 (GET, 헤더 뱃지 폴링용)
  static const String notificationsUnreadCount = '/api/notifications/unread-count';
  /// 전체 읽음 처리 (PATCH)
  static const String notificationsReadAll     = '/api/notifications/read-all';
  /// 단건 읽음 처리 (PATCH)
  static String notificationRead(int id) => '/api/notifications/$id/read';

  // ── 약관 ─────────────────────────────────────────────────────────
  static String cardDetail(int id)     => '/api/cards/$id';
  static String termsPackage(String t) => '/api/terms/packages/$t';
}