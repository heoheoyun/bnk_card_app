import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/models/login_result.dart';
import '../../data/models/signup_request_model.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/push/push_service.dart';

final authDatasourceProvider = Provider<AuthRemoteDatasource>(
      (_) => AuthRemoteDatasource(),
);

final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => AuthRepositoryImpl(ref.watch(authDatasourceProvider)),
);

final loginUsecaseProvider = Provider<LoginUsecase>(
      (ref) => LoginUsecase(ref.watch(authRepositoryProvider)),
);

final logoutUsecaseProvider = Provider<LogoutUsecase>(
      (ref) => LogoutUsecase(ref.watch(authRepositoryProvider)),
);

final signupUsecaseProvider = Provider<SignupUsecase>(
      (ref) => SignupUsecase(ref.watch(authRepositoryProvider)),
);

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final LoginUsecase  _loginUsecase;
  final LogoutUsecase _logoutUsecase;
  final SignupUsecase _signupUsecase;
  final Ref           _ref;

  AuthNotifier(this._loginUsecase, this._logoutUsecase, this._signupUsecase, this._ref)
      : super(const AsyncData(null));

  /// 로그인. 성공/실패는 [state]에, 분기 정보는 반환값으로 전달.
  ///  - null  → 실패(에러)
  ///  - result.requireDeviceVerify=true  → 새 기기 인증 화면으로
  ///  - result.requireDeviceVerify=false → 쿠키 발급 완료, 홈으로
  Future<LoginResult?> login(String email, String password) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(() => _loginUsecase(email, password));
    state = guarded.whenData((_) {});

    if (guarded is AsyncData<LoginResult>) {
      // 전역 로그인 상태 전환(onLogin)과 네비게이션은 호출 측(LoginPage)에서 처리한다.
      // 여기서 onLogin()을 호출하면 authStateProvider 변경 → GoRouter 리다이렉트가
      // LoginPage 를 즉시 언마운트시키고, 이어지는 context.go(목적지)가 mounted 가드에
      // 막혀 '로그인 후 화면이 안 넘어가는' 레이스가 발생한다. (#로그인 네비게이션)
      return guarded.value;
    }
    return null;
  }

  /// 새 기기 인증 — 이메일 코드 발송
  Future<void> sendDeviceEmailCode({
    required String challengeToken,
  }) =>
      _ref.read(authRepositoryProvider)
          .sendDeviceEmailCode(challengeToken: challengeToken);

  /// 새 기기 인증 — 이메일 코드 확인. 성공 시 쿠키 발급 완료 → 로그인 상태 전환.
  Future<void> confirmDeviceEmailCode({
    required String challengeToken,
    required String code,
    String? deviceName,
  }) async {
    await _ref.read(authRepositoryProvider).confirmDeviceEmailCode(
      challengeToken: challengeToken,
      code: code,
      deviceName: deviceName,
    );
    // 전역 로그인 상태 전환(onLogin)/FCM 등록/네비게이션은 호출 측(DeviceVerifyPage)에서 처리한다.
    // 여기서 await onLogin() → registerToken(FCM getToken/네트워크)이 지연·행 되면
    // 인증 후 화면 전환이 그 await 에 막혀 안 넘어가는 문제가 있었다. (#로그인 네비게이션)
  }

  /// 새 기기 인증 — CI 확인. 성공 시 쿠키 발급 완료 → 로그인 상태 전환.
  Future<void> verifyDeviceCi({
    required String challengeToken,
    required String name,
    required String residentFront,
    required String phone,
    String? deviceName,
  }) async {
    await _ref.read(authRepositoryProvider).verifyDeviceCi(
      challengeToken: challengeToken,
      name: name,
      residentFront: residentFront,
      phone: phone,
      deviceName: deviceName,
    );
    // confirmDeviceEmailCode 와 동일: onLogin/네비게이션은 호출 측(DeviceVerifyPage)에서 처리.
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    await PushService.instance.unregister();
    state = await AsyncValue.guard(() => _logoutUsecase());
    await _ref.read(authStateProvider.notifier).onLogout();
  }

  Future<void> signup(SignupRequestModel req) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _signupUsecase(req).then((_) {}));
    if (state is AsyncError) {
      throw (state as AsyncError).error;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
      (ref) => AuthNotifier(
    ref.watch(loginUsecaseProvider),
    ref.watch(logoutUsecaseProvider),
    ref.watch(signupUsecaseProvider),
    ref,
  ),
);