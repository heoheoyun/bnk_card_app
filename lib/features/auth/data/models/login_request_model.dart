class LoginRequestModel {
  final String email;
  final String password;

  /// 신뢰 기기 판정용 (datasource 에서 DeviceIdService 값으로 채워 전송).
  final String? deviceId;
  final String? deviceName;
  final String? platform; // IOS / ANDROID / WEB

  const LoginRequestModel({
    required this.email,
    required this.password,
    this.deviceId,
    this.deviceName,
    this.platform,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        if (deviceId != null) 'deviceId': deviceId,
        if (deviceName != null) 'deviceName': deviceName,
        if (platform != null) 'platform': platform,
      };
}
