/// 신뢰 기기 모델.
///
/// 서버 응답: GET /api/users/me/trusted-devices → TrustedDeviceResponse
///   { deviceTrustId, deviceName, platformCode, lastIpMasked, isInitial,
///     statusCode, lastUsedAt, registeredVia, createdAt }
/// lastIpMasked 는 서버에서 이미 마스킹(192.168.*.*)되어 내려온다.
class TrustedDevice {
  final int deviceTrustId;
  final String? deviceName;
  final String? platformCode; // IOS / ANDROID / WEB / UNKNOWN
  final String? lastIpMasked;
  final bool isInitial;
  final String? statusCode;
  final DateTime? lastUsedAt;
  final String? registeredVia;
  final DateTime? createdAt;

  const TrustedDevice({
    required this.deviceTrustId,
    this.deviceName,
    this.platformCode,
    this.lastIpMasked,
    this.isInitial = false,
    this.statusCode,
    this.lastUsedAt,
    this.registeredVia,
    this.createdAt,
  });

  bool get isActive => statusCode == null || statusCode == 'ACTIVE';

  factory TrustedDevice.fromJson(Map<String, dynamic> j) => TrustedDevice(
        deviceTrustId: (j['deviceTrustId'] as num).toInt(),
        deviceName: j['deviceName'] as String?,
        platformCode: j['platformCode'] as String?,
        lastIpMasked: j['lastIpMasked'] as String?,
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
