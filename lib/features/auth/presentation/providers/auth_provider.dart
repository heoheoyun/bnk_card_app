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
  ///  - result.requireIpVerify=true  → IP 인증 화면으로
  ///  - result.requireIpVerify=false → 쿠키 발급 완료, 홈으로
  Future<LoginResult?> login(String email, String password) async {
    state = const AsyncLoading();
    final guarded = await AsyncValue.guard(() => _loginUsecase(email, password));
    state = guarded.whenData((_) {});

    if (guarded is AsyncData<LoginResult>) {
      final result = guarded.value;
      if (!result.requireIpVerify) {
        // 실제 로그인 완료(쿠키 발급됨)
        await _ref.read(authStateProvider.notifier).onLogin();
        PushService.instance.registerToken();
      }
      return result;
    }
    return null;
  }

  /// IP 인증 — 이메일 코드 발송
  Future<void> sendIpEmailCode({
    required int userId,
    required String challengeToken,
  }) =>
      _ref.read(authRepositoryProvider)
          .sendIpEmailCode(userId: userId, challengeToken: challengeToken);

  /// IP 인증 — 이메일 코드 확인. 성공 시 쿠키 발급 완료 → 로그인 상태 전환.
  Future<void> confirmIpEmailCode({
    required int userId,
    required String challengeToken,
    required String code,
    String? nickname,
  }) async {
    await _ref.read(authRepositoryProvider).confirmIpEmailCode(
      userId: userId,
      challengeToken: challengeToken,
      code: code,
      nickname: nickname,
    );
    await _ref.read(authStateProvider.notifier).onLogin();
    PushService.instance.registerToken();
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