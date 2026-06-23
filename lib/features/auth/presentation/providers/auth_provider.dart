import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/auth_remote_datasource.dart';
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

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loginUsecase(email, password));
    if (state is AsyncData) {
      _ref.read(authStateProvider.notifier).onLogin();
      // 로그인 직후 FCM 디바이스 토큰을 서버에 등록 (실패해도 로그인엔 영향 없음)
      PushService.instance.registerToken();
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    // 토큰(JWT)이 살아있는 동안 서버에서 푸시 토큰을 먼저 해제
    await PushService.instance.unregister();
    state = await AsyncValue.guard(() => _logoutUsecase());
    await _ref.read(authStateProvider.notifier).onLogout();
  }

  Future<void> signup(SignupRequestModel req) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _signupUsecase(req).then((_) {}));
    if (state is AsyncError) {
      final err = (state as AsyncError).error;
      throw err;
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