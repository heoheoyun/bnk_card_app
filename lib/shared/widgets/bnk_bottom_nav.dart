import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
class BnkBottomNav extends StatelessWidget {
  final int currentIndex;
  const BnkBottomNav({super.key, required this.currentIndex});
  @override Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: currentIndex,
    selectedItemColor:   AppColors.primary,
    unselectedItemColor: AppColors.textSecondary,
    type: BottomNavigationBarType.fixed,
    onTap: (i) { const routes = ['/', '/search', '/ai/chat', '/mypage']; context.go(routes[i]); },
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.credit_card), label: '카드'),
      BottomNavigationBarItem(icon: Icon(Icons.search),      label: '검색'),
      BottomNavigationBarItem(icon: Icon(Icons.smart_toy),   label: 'AI'),
      BottomNavigationBarItem(icon: Icon(Icons.person),      label: '마이페이지'),
    ],
  );
}
