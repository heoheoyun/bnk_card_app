class StorageKeys {
  StorageKeys._();

  // ── 인증 토큰 ────────────────────────────────────────────────
  static const String accessToken  = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String isLoggedIn   = 'is_logged_in';

  // ── 기타 ────────────────────────────────────────────────────
  static const String chatSessionId = 'chat_session_id';
  static const String lastEmail     = 'last_email';

  /// 신뢰 기기 판정용 영구 기기 식별자(UUID). 로그아웃해도 보존되어야
  /// 같은 기기가 매번 '새 기기'로 인식되지 않는다. (SharedPreferences 저장)
  static const String deviceId      = 'device_id';

  // ── 간편로그인(Quick Login) ──────────────────────────────────
  /// 지문/얼굴 등 생체인증 사용 여부 ('true' / 'false')
  static const String biometricEnabled = 'biometric_enabled';

  /// 간편비밀번호(PIN) 해시 / 솔트
  static const String pinHash = 'ql_pin_hash';
  static const String pinSalt = 'ql_pin_salt';

  /// 패턴 해시 / 솔트
  static const String patternHash = 'ql_pattern_hash';
  static const String patternSalt = 'ql_pattern_salt';

  /// 간편 인증 연속 실패 횟수 / 잠금 해제 시각(epoch ms)
  static const String quickFailCount = 'ql_fail_count';
  static const String quickLockUntil = 'ql_lock_until';
}