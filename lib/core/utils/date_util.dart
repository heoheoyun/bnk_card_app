class DateUtil {
  DateUtil._();
  static DateTime? parse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }
  static bool isExpired(DateTime? dt) => dt != null && dt.isBefore(DateTime.now());
}
