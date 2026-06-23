import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/auth_state_provider.dart';
import '../../data/datasource/notification_remote_datasource.dart';
import '../../data/models/notification_model.dart';

/// datasource 싱글턴
final notificationDatasourceProvider =
Provider<NotificationRemoteDatasource>((_) => NotificationRemoteDatasource());

/// 알림센터 목록 상태(목록 + 미읽음수). autoDispose 로 페이지 이탈 시 정리.
final notificationListProvider = FutureProvider.autoDispose<
    ({int unreadCount, List<NotificationModel> items})>((ref) async {
  final ds = ref.watch(notificationDatasourceProvider);
  return ds.getMyNotifications();
});

/// 헤더 벨 뱃지용 미읽음 개수.
/// 로그인 시 자동 폴링(60초) 시작, 로그아웃 시 정지 후 0으로 리셋.
class UnreadCountNotifier extends StateNotifier<int> {
  UnreadCountNotifier(this._ref) : super(0) {
    _ref.listen<bool>(
      authStateProvider,
          (_, loggedIn) {
        if (loggedIn) {
          _start();
        } else {
          _stop();
          state = 0;
        }
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;
  Timer? _timer;

  static const _pollInterval = Duration(seconds: 60);

  void _start() {
    _stop();
    refresh();
    _timer = Timer.periodic(_pollInterval, (_) => refresh());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// 즉시 갱신(알림 읽음 처리 직후 호출).
  Future<void> refresh() async {
    if (!_ref.read(authStateProvider)) {
      state = 0;
      return;
    }
    try {
      final ds = _ref.read(notificationDatasourceProvider);
      state = await ds.getUnreadCount();
    } catch (_) {
      // 네트워크 일시 오류는 무시 — 다음 폴링에서 회복
    }
  }

  @override
  void dispose() {
    _stop();
    super.dispose();
  }
}

final unreadCountProvider =
StateNotifierProvider<UnreadCountNotifier, int>(
        (ref) => UnreadCountNotifier(ref));