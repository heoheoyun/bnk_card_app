import 'package:flutter_secure_storage/flutter_secure_storage.dart';
class SecureStorage {
  SecureStorage._();
  static const _s = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static Future<void>    write(String k, String v) => _s.write(key: k, value: v);
  static Future<String?> read(String k)             => _s.read(key: k);
  static Future<void>    delete(String k)           => _s.delete(key: k);
  static Future<void>    deleteAll()                => _s.deleteAll();
}
