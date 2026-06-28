import 'package:flutter/services.dart' show PlatformException;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;

/// 생체인증 결과를 더 세분화해 반환하기 위한 결과 타입.
enum BiometricResult {
  success, // 인증 성공
  canceled, // 사용자가 취소
  unavailable, // 기기 미지원 / 미등록 / 잠금화면 미설정
  locked, // 연속 실패로 일시/영구 잠금
}

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// 기기에서 생체인증 사용 가능한지 확인
  static Future<bool> isAvailable() async {
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      return canCheck && isSupported;
    } catch (_) {
      return false;
    }
  }

  /// 사용 가능한 생체인증 종류 확인
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// 생체인증 실행 (성공/실패만 필요할 때)
  static Future<bool> authenticate({
    String reason = 'BNK 카드 앱 로그인',
  }) async {
    return (await authenticateDetailed(reason: reason)) ==
        BiometricResult.success;
  }

  /// 생체인증 실행 — 실패 원인을 구분해서 반환.
  ///
  /// MainActivity 가 FlutterFragmentActivity 가 아니면 'no_fragment_activity'
  /// 예외가 나며 canceled 로 처리된다(→ MainActivity.kt 수정 필요).
  static Future<BiometricResult> authenticateDetailed({
    String reason = 'BNK 카드 앱 로그인',
    bool biometricOnly = true,
  }) async {
    try {
      final ok = await _auth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: biometricOnly,
          useErrorDialogs: true,
        ),
      );
      return ok ? BiometricResult.success : BiometricResult.canceled;
    } on PlatformException catch (e) {
      switch (e.code) {
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return BiometricResult.locked;
        case auth_error.notAvailable:
        case auth_error.notEnrolled:
        case auth_error.passcodeNotSet:
        // 기기에 지문/얼굴 미등록 또는 잠금화면 미설정 → 사용 불가
          return BiometricResult.unavailable;
        default:
          return BiometricResult.canceled;
      }
    }
  }
}