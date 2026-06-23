// 간편로그인 설정 상태(어떤 수단이 켜져 있는지 + 생체 가능 여부)를 노출.
// 마이페이지 설정 화면이 이 상태를 구독해 토글 UI 를 그린다.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../data/quick_login_service.dart';

final quickLoginServiceProvider = Provider<QuickLoginService>(
  (_) => QuickLoginService.instance,
);

class QuickLoginState {
  final bool pinSet;
  final bool patternSet;
  final bool biometricEnabled;
  final bool biometricAvailable;
  final List<BiometricType> biometricTypes;

  const QuickLoginState({
    this.pinSet = false,
    this.patternSet = false,
    this.biometricEnabled = false,
    this.biometricAvailable = false,
    this.biometricTypes = const [],
  });

  bool get anyEnabled => pinSet || patternSet || biometricEnabled;

  /// 생체 라벨 (지문/얼굴/생체)
  String get biometricLabel {
    if (biometricTypes.contains(BiometricType.face)) return '얼굴 인식';
    if (biometricTypes.contains(BiometricType.fingerprint)) return '지문 인식';
    if (biometricTypes.contains(BiometricType.strong) ||
        biometricTypes.contains(BiometricType.weak)) {
      return '생체 인식';
    }
    return '생체 인식';
  }

  QuickLoginState copyWith({
    bool? pinSet,
    bool? patternSet,
    bool? biometricEnabled,
    bool? biometricAvailable,
    List<BiometricType>? biometricTypes,
  }) =>
      QuickLoginState(
        pinSet: pinSet ?? this.pinSet,
        patternSet: patternSet ?? this.patternSet,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        biometricAvailable: biometricAvailable ?? this.biometricAvailable,
        biometricTypes: biometricTypes ?? this.biometricTypes,
      );
}

class QuickLoginNotifier extends StateNotifier<QuickLoginState> {
  final QuickLoginService _svc;
  QuickLoginNotifier(this._svc) : super(const QuickLoginState()) {
    refresh();
  }

  Future<void> refresh() async {
    final pin = await _svc.isPinSet();
    final pattern = await _svc.isPatternSet();
    final bioOn = await _svc.isBiometricEnabled();
    final bioCan = await _svc.canUseBiometric();
    final bioTypes = await _svc.availableBiometrics();
    state = state.copyWith(
      pinSet: pin,
      patternSet: pattern,
      biometricEnabled: bioOn,
      biometricAvailable: bioCan,
      biometricTypes: bioTypes,
    );
  }

  Future<void> setPin(String pin) async {
    await _svc.setPin(pin);
    await refresh();
  }

  Future<void> disablePin() async {
    await _svc.disablePin();
    await refresh();
  }

  Future<void> setPattern(List<int> points) async {
    await _svc.setPattern(points);
    await refresh();
  }

  Future<void> disablePattern() async {
    await _svc.disablePattern();
    await refresh();
  }

  /// 생체인증 토글. 켤 때 1회 인증 통과 필요.
  Future<bool> toggleBiometric(bool enable) async {
    bool ok = true;
    if (enable) {
      ok = await _svc.enableBiometric();
    } else {
      await _svc.disableBiometric();
    }
    await refresh();
    return ok;
  }

  Future<void> clearAll() async {
    await _svc.clearAll();
    await refresh();
  }
}

final quickLoginProvider =
    StateNotifierProvider<QuickLoginNotifier, QuickLoginState>(
  (ref) => QuickLoginNotifier(ref.watch(quickLoginServiceProvider)),
);
