import 'package:shared_preferences/shared_preferences.dart';
class LocalStorage {
  LocalStorage._();
  static late SharedPreferences _p;
  static Future<void> init() async => _p = await SharedPreferences.getInstance();
  static Future<void> setBool(String k, bool v)   => _p.setBool(k, v);
  static bool?        getBool(String k)            => _p.getBool(k);
  static Future<void> setString(String k, String v) => _p.setString(k, v);
  static String?      getString(String k)            => _p.getString(k);
  static Future<void> remove(String k)             => _p.remove(k);
}
