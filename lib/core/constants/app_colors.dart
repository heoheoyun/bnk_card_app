import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Teal 팔레트 ──────────────────────────────────────────────────
  static const Color teal50  = Color(0xFFE0F4F7);
  static const Color teal100 = Color(0xFFB3E3EC);
  static const Color teal200 = Color(0xFF7ECFDD);
  static const Color teal400 = Color(0xFF3AAFC4);
  static const Color teal600 = Color(0xFF00677F);
  static const Color teal800 = Color(0xFF004D61);
  static const Color teal900 = Color(0xFF003040);

  // ── Gray 팔레트 ──────────────────────────────────────────────────
  static const Color gray50  = Color(0xFFF8FAFB);
  static const Color gray100 = Color(0xFFF0F4F5);
  static const Color gray200 = Color(0xFFDDE6E9);
  static const Color gray400 = Color(0xFF9BB4BB);
  static const Color gray600 = Color(0xFF5C7A83);
  static const Color gray800 = Color(0xFF2C3E42);

  // ── 시맨틱 ──────────────────────────────────────────────────────
  static const Color primary      = teal600;
  static const Color primaryDark  = teal800;
  static const Color background   = gray100;
  static const Color surface      = Colors.white;
  static const Color textPrimary  = gray800;
  static const Color textMuted    = gray600;
  static const Color textHint     = gray400;
  static const Color divider      = gray200;

  /// [textSecondary] 는 [textMuted] 의 alias — 기존 코드 호환용
  static const Color textSecondary = textMuted;

  // ── 카드 타입 배지 색상 ──────────────────────────────────────────
  /// 신용카드
  static const Color credit  = Color(0xFF1A56DB); // 파란 계열
  /// 체크카드
  static const Color check   = Color(0xFF057A55); // 초록 계열
  /// 선불카드
  static const Color prepaid = Color(0xFF9F580A); // 주황 계열
}