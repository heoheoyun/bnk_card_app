import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_state_provider.dart';

/// GoRouter 의 [refreshListenable] 에 전달하는 ChangeNotifier 어댑터.
///
/// [authStateProvider] 값이 바뀔 때마다 GoRouter 에 리다이렉트
/// 재평가를 요청한다.
class RouterNotifier extends ChangeNotifier {
  RouterNotifier(Ref ref) {
    ref.listen<bool>(authStateProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = ChangeNotifierProvider<RouterNotifier>(
      (ref) => RouterNotifier(ref),
);