/// 로그인 결과.
///  - requireIpVerify=false → 쿠키 발급 완료 (홈으로)
///  - requireIpVerify=true  → 미신뢰 기기, IP 2단계 인증 필요
class LoginResult {
  final bool requireIpVerify;
  final int? userId;
  final String? challengeToken;
  final List<String> availableMethods;

  const LoginResult._({
    required this.requireIpVerify,
    this.userId,
    this.challengeToken,
    this.availableMethods = const [],
  });

  factory LoginResult.success() =>
      const LoginResult._(requireIpVerify: false);

  factory LoginResult.ipVerify({
    required int userId,
    required String challengeToken,
    required List<String> availableMethods,
  }) =>
      LoginResult._(
        requireIpVerify: true,
        userId: userId,
        challengeToken: challengeToken,
        availableMethods: availableMethods,
      );
}