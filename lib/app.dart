import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/push/push_service.dart';
import 'core/providers/auth_state_provider.dart';
import 'features/quick_login/presentation/providers/quick_login_provider.dart';

class BnkCardApp extends ConsumerStatefulWidget {
  const BnkCardApp({super.key});

  @override
  ConsumerState<BnkCardApp> createState() => _BnkCardAppState();
}

class _BnkCardAppState extends ConsumerState<BnkCardApp>
    with WidgetsBindingObserver {
  // #1 — 백그라운드 진입 시각. 일정 시간 이상 체류 후 복귀하면 재잠금한다.
  DateTime? _pausedAt;
  static const _relockAfter = Duration(seconds: 60);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // #1 생명주기 관찰 시작

    // 라우터가 준비된 첫 프레임 이후 푸시 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final router = ref.read(appRouterProvider);

      await PushService.instance.init(onTap: (linkUrl) {
        // 알림 탭 시 라우팅: /cards/* 는 해당 카드로, 그 외엔 알림센터로
        final target = (linkUrl != null && linkUrl.startsWith('/cards/'))
            ? linkUrl
            : '/notifications';
        router.go(target);
      });

      // 앱 시작 시 이미 로그인 상태면 현재 디바이스 토큰을 서버에 등록
      if (ref.read(authStateProvider)) {
        await PushService.instance.registerToken();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // #1 관찰 해제
    super.dispose();
  }

  // #1 — 앱 생명주기 처리
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _pausedAt = DateTime.now();
        break;
      case AppLifecycleState.resumed:
        _maybeRelock();
        break;
      default:
        break;
    }
  }

  /// 일정 시간 이상 백그라운드 체류 후 복귀 시, 로그인+간편인증 사용자라면
  /// 간편인증 게이트('/unlock')로 보내 재인증을 요구한다.
  /// (안드로이드 프로세스 강제 종료는 OS 권한이라 막을 수 없지만,
  ///  복귀 시 재잠금으로 동일한 보안 효과를 낸다.)
  Future<void> _maybeRelock() async {
    final pausedAt = _pausedAt;
    _pausedAt = null;
    if (pausedAt == null) return;
    if (DateTime.now().difference(pausedAt) < _relockAfter) return;

    if (!ref.read(authStateProvider)) return; // 비로그인이면 잠글 것 없음

    final methods =
    await ref.read(quickLoginServiceProvider).enabledMethods();
    if (methods.isEmpty) return; // 간편인증 미설정이면 재잠금 생략

    ref.read(appRouterProvider).go('/unlock');
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'BNK 카드',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}