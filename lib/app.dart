import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/push/push_service.dart';
import 'core/providers/auth_state_provider.dart';

class BnkCardApp extends ConsumerStatefulWidget {
  const BnkCardApp({super.key});

  @override
  ConsumerState<BnkCardApp> createState() => _BnkCardAppState();
}

class _BnkCardAppState extends ConsumerState<BnkCardApp> {
  @override
  void initState() {
    super.initState();
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