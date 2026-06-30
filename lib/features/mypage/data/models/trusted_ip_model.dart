/// 신뢰 기기(IP) 모델.
///
/// 서버 응답: GET /api/users/me/trusted-ips → TrustedIpResponse
///   { trustId, ipAddressMasked, nickname, isInitial, statusCode,
///     lastUsedAt, registeredVia, createdAt }
/// IP는 서버에서 이미 마스킹(192.168.*.*)되어 내려온다.
class TrustedIp {
  final int trustId;
  final String? ipAddressMasked;
  final String? nickname;
  final bool isInitial;
  final String? statusCode;
  final DateTime? lastUsedAt;
  final String? registeredVia;
  final DateTime? createdAt;

  const TrustedIp({
    required this.trustId,
    this.ipAddressMasked,
    this.nickname,
    this.isInitial = false,
    this.statusCode,
    this.lastUsedAt,
    this.registeredVia,
    this.createdAt,
  });

  bool get isActive => statusCode == null || statusCode == 'ACTIVE';

  factory TrustedIp.fromJson(Map<String, dynamic> j) => TrustedIp(
        trustId: (j['trustId'] as num).toInt(),
        ipAddressMasked: j['ipAddressMasked'] as String?,
        nickname: j['nickname'] as String?,
        isInitial: j['isInitial'] == true,
        statusCode: j['statusCode'] as String?,
        lastUsedAt: _parseDate(j['lastUsedAt']),
        registeredVia: j['registeredVia'] as String?,
        createdAt: _parseDate(j['createdAt']),
      );

  static DateTime? _parseDate(Object? v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
