import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/home_header.dart';
import '../widgets/my_card_carousel.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/quick_menu_grid.dart';
import '../widgets/home_banner.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const HomeHeader(),
              const MyCardCarousel(),
              const SizedBox(height: 12),
              const SpendingSummaryCard(),
              const SizedBox(height: 8),
              const QuickMenuGrid(),
              const SizedBox(height: 8),
              const HomeBanner(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      // currentIndex: 0 = 홈, onTap 은 BnkBottomNav 내부 GoRouter 로 처리
      bottomNavigationBar: const BnkBottomNav(currentIndex: 0),
    );
  }
}