class AppConfig {
  AppConfig._();

  /// Android 에뮬레이터 host 머신: 10.0.2.2
  /// 실기기·운영: --dart-define=BASE_URL=https://api.bnkcard.store
  /// ngrok URL https://curable-cranium-handwoven.ngrok-free.dev
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.50.30:8088',
  );

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static const String accessTokenCookie  = 'access_token';
  static const String refreshTokenCookie = 'refresh_token';
}