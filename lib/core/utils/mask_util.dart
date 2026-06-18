class MaskUtil {
  MaskUtil._();
  static String email(String email) {
    final at = email.indexOf('@');
    if (at < 2) return email;
    return '${email.substring(0, 2)}${'*' * (at - 2)}${email.substring(at)}';
  }
  static String phone(String phone) => phone.replaceRange(4, 8, '****');
}
