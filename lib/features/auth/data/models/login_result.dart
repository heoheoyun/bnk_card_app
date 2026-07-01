/// 로그인 결과.
///  - requireDeviceVerify=false → 쿠키 발급 완료 (홈으로)
///  - requireDeviceVerify=true  → 미신뢰 기기, 새 기기 인증 필요
///
/// challengeToken 은 서버가 발급한 불투명 난수 토큰이다(내부 키 구조 미노출).
class LoginResult {
  final bool requireDeviceVerify;
  final String? challengeToken;
  final List<String> availableMethods;

  const LoginResult._({
    required this.requireDeviceVerify,
    this.challengeToken,
    this.availableMethods = const [],
  });

  factory LoginResult.success() =>
      const LoginResult._(requireDeviceVerify: false);

  factory LoginResult.deviceVerify({
    required String challengeToken,
    required List<String> availableMethods,
  }) =>
      LoginResult._(
        requireDeviceVerify: true,
        challengeToken: challengeToken,
        availableMethods: availableMethods,
      );
}
