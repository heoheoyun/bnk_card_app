import 'package:intl/intl.dart';
class FormatUtil {
  FormatUtil._();
  static final _won = NumberFormat('#,###', 'ko_KR');
  static String won(int amount)       => '\u20A9${_won.format(amount)}';
  static String wonOrFree(int amount) => amount == 0 ? '연회비 없음' : won(amount);
  static String date(DateTime dt)     => DateFormat('yyyy.MM.dd').format(dt);
}
