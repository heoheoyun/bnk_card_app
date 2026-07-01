import 'dart:io' show Platform;
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// 이 기기의 신뢰 판정 컨텍스트.
///  - [id]       : 영구 기기 UUID (서버는 SHA-256 해시로만 저장/비교)
///  - [name]     : 표시용 기기명 (예: iPhone 15 Pro, samsung SM-S921N)
///  - [platform] : IOS / ANDROID / UNKNOWN
class DeviceContext {
  final String id;
  final String name;
  final String platform;
  const DeviceContext({required this.id, required this.name, required this.platform});
}

/// 기기 식별자 관리 서비스.
///
/// 로그인/회원가입/기기 인증 요청에 실어 보낼 기기 컨텍스트를 제공한다.
/// UUID는 최초 1회 생성해 SharedPreferences에 영구 저장하며, 로그아웃해도
/// 유지되어 같은 기기가 매번 '새 기기'로 인식되지 않는다.
class DeviceIdService {
  DeviceIdService._();
  static final DeviceIdService instance = DeviceIdService._();

  DeviceContext? _cache;

  /// 이 기기의 컨텍스트(id/name/platform). 결과는 메모리에 캐시된다.
  Future<DeviceContext> current() async {
    if (_cache != null) return _cache!;
    final id       = await _loadOrCreateId();
    final platform = _platformCode();
    final name     = await _resolveDeviceName(platform);
    return _cache = DeviceContext(id: id, name: name, platform: platform);
  }

  Future<String> _loadOrCreateId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getString(StorageKeys.deviceId);
    if (id == null || id.isEmpty) {
      id = _uuidV4();
      await prefs.setString(StorageKeys.deviceId, id);
    }
    return id;
  }

  String _platformCode() {
    if (Platform.isIOS) return 'IOS';
    if (Platform.isAndroid) return 'ANDROID';
    return 'UNKNOWN';
  }

  Future<String> _resolveDeviceName(String platform) async {
    try {
      final plugin = DeviceInfoPlugin();
      if (platform == 'ANDROID') {
        final a = await plugin.androidInfo;
        final brand = a.manufacturer.isEmpty ? '' : a.manufacturer;
        return '$brand ${a.model}'.trim();
      }
      if (platform == 'IOS') {
        final i = await plugin.iosInfo;
        // iOS 16+ 는 프라이버시 정책상 i.name 이 사용자 지정명 대신 모델명일 수 있다.
        return i.name.isNotEmpty ? i.name : i.utsname.machine;
      }
    } catch (_) {
      // 기기 정보 조회 실패 시 일반 라벨로 폴백
    }
    return switch (platform) {
      'IOS'     => 'iPhone',
      'ANDROID' => 'Android 기기',
      _         => '내 기기',
    };
  }

  /// RFC 4122 v4 UUID (Random.secure 기반).
  String _uuidV4() {
    final r = Random.secure();
    final b = List<int>.generate(16, (_) => r.nextInt(256));
    b[6] = (b[6] & 0x0f) | 0x40; // version 4
    b[8] = (b[8] & 0x3f) | 0x80; // variant 10
    String hex(int n) => n.toRadixString(16).padLeft(2, '0');
    final h = b.map(hex).toList();
    return '${h[0]}${h[1]}${h[2]}${h[3]}-${h[4]}${h[5]}-${h[6]}${h[7]}-'
        '${h[8]}${h[9]}-${h[10]}${h[11]}${h[12]}${h[13]}${h[14]}${h[15]}';
  }
}
