import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasource/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../../../core/providers/auth_state_provider.dart';

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

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  final LoginUsecase  _loginUsecase;
  final LogoutUsecase _logoutUsecase;
  final Ref           _ref;

  AuthNotifier(this._loginUsecase, this._logoutUsecase, this._ref)
      : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loginUsecase(email, password));
    // 로그인 성공 시 authStateProvider 에 알려 GoRouter redirect 재평가
    if (state is AsyncData) {
      _ref.read(authStateProvider.notifier).onLogin();
    }
  }

  Future<void> logout() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _logoutUsecase());
    // 성공·실패 모두 로컬 상태 초기화
    await _ref.read(authStateProvider.notifier).onLogout();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
      (ref) => AuthNotifier(
    ref.watch(loginUsecaseProvider),
    ref.watch(logoutUsecaseProvider),
    ref,
  ),
);