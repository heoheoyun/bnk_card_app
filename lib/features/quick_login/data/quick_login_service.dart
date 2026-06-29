// 간편로그인 핵심 로직.
//  - PIN / 패턴: 솔트 + SHA-256 해시로 SecureStorage 에 저장 (원문 미저장)
//  - 생체인증: local_auth (지문 / 얼굴)
//  - 잠금: 연속 5회 실패 시 간편 인증 비활성화 → 비밀번호 재로그인 강제
//

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/storage/secure_storage.dart';

/// 간편 인증 수단
enum QuickLoginMethod { pin, pattern, biometric }

/// 간편 인증 검증 결과
enum QuickAuthResult {
  success,
  wrong,        // 값 불일치 (시도 가능)
  locked,       // 잠금 상태 — 비밀번호 재로그인 필요
  unavailable,  // 해당 수단 미설정/미지원
  canceled,     // 사용자가 취소 (주로 생체인증)
}

class QuickLoginService {
  QuickLoginService._();
  static final QuickLoginService instance = QuickLoginService._();

  static const int _maxFail = 5; // 연속 실패 허용 횟수

  final LocalAuthentication _localAuth = LocalAuthentication();

  // ── 활성화 상태 조회 ────────────────────────────────────────────────

  Future<bool> isPinSet() async =>
      (await SecureStorage.read(StorageKeys.pinHash)) != null;

  Future<bool> isPatternSet() async =>
      (await SecureStorage.read(StorageKeys.patternHash)) != null;

  Future<bool> isBiometricEnabled() async =>
      (await SecureStorage.read(StorageKeys.biometricEnabled)) == 'true';

  /// 현재 단말에 활성화된 간편 인증 수단 집합
  Future<Set<QuickLoginMethod>> enabledMethods() async {
    final result = <QuickLoginMethod>{};
    if (await isPinSet()) result.add(QuickLoginMethod.pin);
    if (await isPatternSet()) result.add(QuickLoginMethod.pattern);
    if (await isBiometricEnabled()) result.add(QuickLoginMethod.biometric);
    return result;
  }

  Future<bool> get isAnyEnabled async => (await enabledMethods()).isNotEmpty;

  // ── PIN ────────────────────────────────────────────────────────────

  /// PIN 설정/변경. 4~6자리 숫자 권장(검증은 호출부에서).
  Future<void> setPin(String pin) async {
    final salt = _genSalt();
    await SecureStorage.write(StorageKeys.pinSalt, salt);
    await SecureStorage.write(StorageKeys.pinHash, _hash(pin, salt));
    await _resetFail();
  }

  Future<void> disablePin() async {
    await SecureStorage.delete(StorageKeys.pinHash);
    await SecureStorage.delete(StorageKeys.pinSalt);
  }

  Future<QuickAuthResult> verifyPin(String pin) async {
    if (await isLocked()) return QuickAuthResult.locked;
    final hash = await SecureStorage.read(StorageKeys.pinHash);
    final salt = await SecureStorage.read(StorageKeys.pinSalt);
    if (hash == null || salt == null) return QuickAuthResult.unavailable;

    if (_constEquals(hash, _hash(pin, salt))) {
      await _resetFail();
      return QuickAuthResult.success;
    }
    return await _registerFail();
  }

  // ── 패턴 ────────────────────────────────────────────────────────────

  /// 패턴 설정/변경. [points] 는 선택한 노드 인덱스 순서(예: [0,1,2,5,8]).
  Future<void> setPattern(List<int> points) async {
    final salt = _genSalt();
    await SecureStorage.write(StorageKeys.patternSalt, salt);
    await SecureStorage.write(
        StorageKeys.patternHash, _hash(points.join('-'), salt));
    await _resetFail();
  }

  Future<void> disablePattern() async {
    await SecureStorage.delete(StorageKeys.patternHash);
    await SecureStorage.delete(StorageKeys.patternSalt);
  }

  Future<QuickAuthResult> verifyPattern(List<int> points) async {
    if (await isLocked()) return QuickAuthResult.locked;
    final hash = await SecureStorage.read(StorageKeys.patternHash);
    final salt = await SecureStorage.read(StorageKeys.patternSalt);
    if (hash == null || salt == null) return QuickAuthResult.unavailable;

    if (_constEquals(hash, _hash(points.join('-'), salt))) {
      await _resetFail();
      return QuickAuthResult.success;
    }
    return await _registerFail();
  }

  // ── 생체인증 ────────────────────────────────────────────────────────

  /// 단말이 생체인증을 지원하는지(하드웨어 + 사용 가능).
  /// getAvailableBiometrics()는 기기/버전에 따라 빈 값이 와도 실제론
  /// 사용 가능한 경우가 있어, 가용성 판정에서 제외한다.
  Future<bool> canUseBiometric() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }

  /// 사용 가능한 생체 유형 목록 (UI 라벨용: 지문/얼굴)
  Future<List<BiometricType>> availableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// 생체인증 사용 설정. 1회 인증 통과 시에만 등록.
  Future<bool> enableBiometric() async {
    final ok = await _authenticateBiometric('생체인증을 등록하려면 인증해 주세요.');
    if (ok == QuickAuthResult.success) {
      await SecureStorage.write(StorageKeys.biometricEnabled, 'true');
      return true;
    }
    return false;
  }

  Future<void> disableBiometric() async {
    await SecureStorage.write(StorageKeys.biometricEnabled, 'false');
  }

  Future<QuickAuthResult> verifyBiometric() async {
    if (await isLocked()) return QuickAuthResult.locked;
    if (!await isBiometricEnabled()) return QuickAuthResult.unavailable;
    return _authenticateBiometric('잠금을 해제하려면 생체인증을 진행해 주세요.');
  }

  /// 생체인증 시스템 다이얼로그를 BNK 카드 앱 톤의 한글 문구로 브랜딩.
  /// (OS 보안 정책상 다이얼로그 UI 자체는 교체 불가 — 제목/안내/버튼 문구만 커스터마이즈)
  static const List<AuthMessages> _authMessages = [
    AndroidAuthMessages(
      signInTitle: 'BNK 카드 잠금 해제',
      biometricHint: '지문 또는 얼굴로 본인 확인',
      biometricNotRecognized: '인식하지 못했어요. 다시 시도해 주세요.',
      biometricSuccess: '인증되었습니다.',
      biometricRequiredTitle: '생체인증이 필요합니다',
      cancelButton: '취소',
      deviceCredentialsRequiredTitle: '기기 잠금 설정 필요',
      deviceCredentialsSetupDescription: '기기 설정에서 화면 잠금을 먼저 설정해 주세요.',
      goToSettingsButton: '설정으로 이동',
      goToSettingsDescription: '생체인증이 등록되어 있지 않습니다. 기기 설정에서 등록해 주세요.',
    ),
    IOSAuthMessages(
      cancelButton: '취소',
      goToSettingsButton: '설정',
      goToSettingsDescription: '생체인증을 사용하려면 기기 설정에서 등록해 주세요.',
      lockOut: '생체인증이 잠겼습니다. 기기 비밀번호로 잠금을 해제해 주세요.',
    ),
  ];

  Future<QuickAuthResult> _authenticateBiometric(String reason) async {
    try {
      final ok = await _localAuth.authenticate(
        localizedReason: reason,
        authMessages: _authMessages,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return ok ? QuickAuthResult.success : QuickAuthResult.canceled;
    } catch (e) {
      // 생체 잠금(연속 실패 등) → 비밀번호 로그인으로 폴백
      if (e is PlatformException &&
          (e.code == auth_error.lockedOut ||
              e.code == auth_error.permanentlyLockedOut)) {
        return QuickAuthResult.locked;
      }
      return QuickAuthResult.canceled;
    }
  }

  // ── 잠금(Lockout) ───────────────────────────────────────────────────

  Future<bool> isLocked() async {
    final until = int.tryParse(
            await SecureStorage.read(StorageKeys.quickLockUntil) ?? '') ??
        0;
    return DateTime.now().millisecondsSinceEpoch < until;
  }

  Future<int> _failCount() async =>
      int.tryParse(
          await SecureStorage.read(StorageKeys.quickFailCount) ?? '') ??
      0;

  Future<QuickAuthResult> _registerFail() async {
    final next = await _failCount() + 1;
    await SecureStorage.write(StorageKeys.quickFailCount, '$next');
    if (next >= _maxFail) {
      // 5회 실패 → 모든 간편 수단 해제, 비밀번호 재로그인 강제
      await clearAll();
      // 잠깐 잠금 표시 후 게이트에서 로그인으로 보내도록 lockUntil 설정
      await SecureStorage.write(
        StorageKeys.quickLockUntil,
        '${DateTime.now().add(const Duration(seconds: 1)).millisecondsSinceEpoch}',
      );
      return QuickAuthResult.locked;
    }
    return QuickAuthResult.wrong;
  }

  Future<void> _resetFail() async {
    await SecureStorage.delete(StorageKeys.quickFailCount);
    await SecureStorage.delete(StorageKeys.quickLockUntil);
  }

  /// 남은 시도 횟수 (UI 안내용)
  Future<int> remainingAttempts() async => _maxFail - await _failCount();

  // ── 전체 해제 (로그아웃/계정 변경 시 호출) ───────────────────────────

  Future<void> clearAll() async {
    await disablePin();
    await disablePattern();
    await disableBiometric();
    await SecureStorage.delete(StorageKeys.quickFailCount);
    await SecureStorage.delete(StorageKeys.quickLockUntil);
  }

  // ── 해시 유틸 ───────────────────────────────────────────────────────

  String _hash(String input, String salt) =>
      sha256.convert(utf8.encode('$salt::$input')).toString();

  String _genSalt() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// 길이·내용 비교 (타이밍 측면 보강)
  bool _constEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
