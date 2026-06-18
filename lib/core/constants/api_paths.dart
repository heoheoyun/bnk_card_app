class ApiPaths {
  ApiPaths._();
  static const String sendVerifyCode    = '/api/auth/send-verify-code';
  static const String verifyEmail       = '/api/auth/verify-email';
  static const String signup            = '/api/auth/signup';
  static const String login             = '/api/auth/login';
  static const String logout            = '/api/auth/logout';
  static const String refresh           = '/api/auth/refresh';
  static const String findId            = '/api/auth/find-id';
  static const String findPassword      = '/api/auth/find-password';
  static const String resetPassword     = '/api/auth/reset-password';
  static const String homeBanners       = '/api/home/banners';
  static const String cards             = '/api/cards';
  static const String cardsTop3         = '/api/cards/top3';
  static const String cardCategories    = '/api/cards/categories';
  static const String cardCompare       = '/api/cards/compare';
  static const String search            = '/api/search';
  static const String suggestKeywords   = '/api/search/keywords/suggest';
  static const String popularKeywords   = '/api/search/keywords/popular';
  static const String chat              = '/api/chat';
  static const String chatHistory       = '/api/chat/history';
  static const String mySpending        = '/api/users/me/spending';
  static const String myInfo            = '/api/users/me';
  static const String myPassword        = '/api/users/me/password';
  static const String myCards           = '/api/users/me/cards';
  static String cardDetail(int id)      => '/api/cards/$id';
  static String termsPackage(String t)  => '/api/terms/packages/$t';
}
