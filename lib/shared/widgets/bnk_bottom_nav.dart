import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

/// GoRouter 기반 BottomNavigationBar.
///
/// [currentIndex] 로 현재 탭을 강조하고, 탭 클릭 시 GoRouter 경로로 이동한다.
/// 기존 [onTap] 콜백 파라미터를 제거하여 각 Page 에서 setState 불필요.
class BnkBottomNav extends StatelessWidget {
  final int currentIndex;

  const BnkBottomNav({
    super.key,
    required this.currentIndex,
  });

  static const _routes = ['/', '/search', '/ai/chat', '/mypage'];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child:BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (i) {
        if (i != currentIndex) context.go(_routes[i]);
      },
      selectedItemColor:   AppColors.primary,
      unselectedItemColor: AppColors.gray400,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon:       Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: '홈',
        ),
        BottomNavigationBarItem(
          icon:       Icon(Icons.credit_card_outlined),
          activeIcon: Icon(Icons.credit_card),
          label: '카드',
        ),
        BottomNavigationBarItem(
          icon:       Icon(Icons.smart_toy_outlined),
          activeIcon: Icon(Icons.smart_toy),
          label: 'AI 추천',
        ),
        BottomNavigationBarItem(
          icon:       Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: '마이페이지',
        ),
      ],
    ),
    );
  }
}