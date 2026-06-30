import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 하단탭 루트(검색 · AI 추천 · 마이페이지)의 시스템 뒤로가기 처리.
///
/// 이 탭들은 BottomNavigationBar 로 [context.go] 되어 진입하므로 라우터 스택이
/// 비어 있다. 그대로 두면 안드로이드 뒤로가기 시 앱이 종료되므로, 홈('/')으로
/// 돌려보내 "탭 → 뒤로가기 → 홈" 흐름을 일관되게 만든다.
/// (홈 탭은 [HomePage] 가 '한 번 더 누르면 종료'를 별도로 처리한다)
class HomeBackScope extends StatelessWidget {
  final Widget child;
  const HomeBackScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          context.go('/');
        },
        child: child,
      );
}
