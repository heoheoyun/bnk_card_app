import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/my_card_carousel.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/quick_menu_grid.dart';
import '../widgets/home_banner.dart';
import '../widgets/guest_home_body.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              if (isLoggedIn) ...[
                const HomeHeader(),
                const MyCardCarousel(),
                const SizedBox(height: 12),
                const SpendingSummaryCard(),
                const SizedBox(height: 8),
                const QuickMenuGrid(),
                const SizedBox(height: 8),
                const HomeBanner(),
              ] else ...[
                const GuestHomeBody(),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BnkBottomNav(currentIndex: 0),
    );
  }
}