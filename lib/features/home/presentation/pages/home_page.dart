import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../widgets/home_header.dart';
import '../widgets/my_card_carousel.dart';
import '../widgets/spending_summary_card.dart';
import '../widgets/quick_menu_grid.dart';
import '../widgets/home_banner.dart';
import '../widgets/guest_home_body.dart';
import '../../../../shared/widgets/bnk_bottom_nav.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  /// 마지막 뒤로가기 시각. 2초 내 두 번 누르면 종료한다.
  DateTime? _lastBack;

  void _handleBack() {
    final now = DateTime.now();
    if (_lastBack == null ||
        now.difference(_lastBack!) > const Duration(seconds: 2)) {
      // 첫 번째 뒤로가기 → 안내 스낵바만 표시
      _lastBack = now;
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('한 번 더 누르면 종료됩니다'),
            duration: Duration(seconds: 2),
          ),
        );
      return;
    }
    // 2초 내 두 번째 뒤로가기 → 세션 상태만 초기화 후 앱 종료
    ref.read(authStateProvider.notifier).resetSessionForExit();
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = ref.watch(authStateProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
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
      ),
    );
  }
}
