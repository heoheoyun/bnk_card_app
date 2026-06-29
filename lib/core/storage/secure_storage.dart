import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorage {
  SecureStorage._();
  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// 간편로그인 관련 키 — 로그아웃 시 보존 대상
  static const _quickLoginKeys = {
    StorageKeys.biometricEnabled,
    StorageKeys.pinHash,
    StorageKeys.pinSalt,
    StorageKeys.patternHash,
    StorageKeys.patternSalt,
    StorageKeys.quickFailCount,
    StorageKeys.quickLockUntil,
  };

  static Future<void>    write(String k, String v) => _s.write(key: k, value: v);
  static Future<String?> read(String k)             => _s.read(key: k);
  static Future<void>    delete(String k)           => _s.delete(key: k);
  static Future<void>    deleteAll()                => _s.deleteAll();

  /// 간편로그인 키(생체/PIN/패턴 해시·솔트, 실패횟수, 잠금시각)는 보존하고
  /// 그 외 시큐어스토리지 항목(access/refresh token 등)만 삭제한다.
  static Future<void> deleteSessionOnly() async {
    final all = await _s.readAll();
    for (final key in all.keys) {
      if (!_quickLoginKeys.contains(key)) {
        await _s.delete(key: key);
      }
    }
  }
}
