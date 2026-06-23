import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/mypage/data/datasource/mypage_remote_datasource.dart';

/// 백그라운드(앱 종료/백그라운드)에서 메시지 수신 시 호출되는 top-level 핸들러.
/// 반드시 최상위 함수여야 하며 @pragma 로 트리쉐이킹을 막는다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드에서는 시스템이 알림 트레이에 자동 표시한다.
  // 별도 처리가 필요하면 여기서 수행(여기선 로깅만).
  debugPrint('[Push] background message: ${message.messageId}');
}

/// FCM 푸시 수신/등록을 총괄하는 싱글턴 서비스.
///
/// 사용 순서:
///   1) main() 에서 Firebase.initializeApp() 후 PushService.instance.init(onTap: ...)
///   2) 로그인 성공 직후 PushService.instance.registerToken()
///   3) 로그아웃 시 PushService.instance.unregister()
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local =
  FlutterLocalNotificationsPlugin();
  final MypageRemoteDatasource _userDs = MypageRemoteDatasource();

  /// 알림 탭 시 linkUrl 로 라우팅하기 위한 콜백(앱에서 주입).
  void Function(String? linkUrl)? _onTap;

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _onOpenedSub;

  static const _androidChannel = AndroidNotificationChannel(
    'bnk_default_channel',
    'BNK 알림',
    description: '카드 혜택·약관·이벤트 등 알림',
    importance: Importance.high,
  );

  /// 앱 시작 시 1회 호출. 권한 요청 + 로컬알림 채널 + 메시지 리스너 등록.
  Future<void> init({void Function(String? linkUrl)? onTap}) async {
    if (_initialized) {
      _onTap = onTap ?? _onTap;
      return;
    }
    _onTap = onTap;

    // 1) 알림 권한 (iOS/Android13+)
    await _fm.requestPermission(alert: true, badge: true, sound: true);

    // 2) 로컬 알림 초기화(포그라운드 표시용)
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (resp) => _onTap?.call(resp.payload),
    );
    await _local
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    // 3) 포그라운드 수신 → 로컬 알림으로 직접 표시(포그라운드에선 트레이에 자동 표시 안 됨)
    _onMessageSub = FirebaseMessaging.onMessage.listen(_showForeground);

    // 4) 백그라운드 상태에서 알림 탭으로 앱 진입
    _onOpenedSub = FirebaseMessaging.onMessageOpenedApp
        .listen((m) => _onTap?.call(m.data['linkUrl'] as String?));

    // 5) 앱이 완전히 종료된 상태에서 알림 탭으로 진입한 경우
    final initial = await _fm.getInitialMessage();
    if (initial != null) {
      // 라우터 준비 후 처리되도록 한 프레임 뒤 호출
      Future.delayed(const Duration(milliseconds: 600),
              () => _onTap?.call(initial.data['linkUrl'] as String?));
    }

    // 6) 토큰 갱신 시 서버 재등록
    _tokenRefreshSub = _fm.onTokenRefresh.listen((t) {
      _userDs.registerPushToken(t).catchError((_) {});
    });

    _initialized = true;
  }

  /// 로그인 직후 호출 — 현재 디바이스 토큰을 서버에 등록.
  Future<void> registerToken() async {
    try {
      final token = await _fm.getToken();
      if (token != null) await _userDs.registerPushToken(token);
    } catch (e) {
      debugPrint('[Push] registerToken 실패: $e');
    }
  }

  /// 로그아웃 시 호출 — 서버 토큰 제거 + 디바이스 토큰 폐기.
  Future<void> unregister() async {
    try {
      await _userDs.clearPushToken();
    } catch (_) {/* 서버 실패는 무시 */}
    try {
      await _fm.deleteToken();
    } catch (_) {}
  }

  Future<void> _showForeground(RemoteMessage m) async {
    final n = m.notification;
    if (n == null) return;
    await _local.show(
      n.hashCode,
      n.title,
      n.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _androidChannel.id,
          _androidChannel.name,
          channelDescription: _androidChannel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      payload: m.data['linkUrl'] as String?,
    );
  }

  void dispose() {
    _tokenRefreshSub?.cancel();
    _onMessageSub?.cancel();
    _onOpenedSub?.cancel();
  }
}