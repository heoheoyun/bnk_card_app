import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/storage_keys.dart';
import '../storage/local_storage.dart';
import '../storage/secure_storage.dart';

/// 앱 전역 로그인 상태 Notifier.
///
/// - 앱 시작: SecureStorage 에서 accessToken 존재 여부로 상태 복원
/// - 로그인 성공: [onLogin] 호출 → state = true
/// - 로그아웃 / 토큰 만료: [onLogout] 호출 → 토큰 삭제 + state = false
///
/// GoRouter [RouterNotifier] 가 이 상태를 구독하여
/// 상태 변경 시 redirect 를 자동 재평가한다.
class AuthStateNotifier extends StateNotifier<bool> {
  AuthStateNotifier() : super(false) {
    _init();
  }

  Future<void> _init() async {
    final token = await SecureStorage.read(StorageKeys.accessToken);
    state = token != null;
  }

  /// 로그인 성공 후 호출
  void onLogin() => state = true;

  /// 로그아웃 혹은 강제 만료 후 호출
  Future<void> onLogout() async {
    await SecureStorage.deleteAll();
    await LocalStorage.remove(StorageKeys.isLoggedIn);
    state = false;
  }
}

final authStateProvider =
StateNotifierProvider<AuthStateNotifier, bool>(
      (_) => AuthStateNotifier(),
);