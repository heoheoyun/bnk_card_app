import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../../core/network/cookie_store.dart';
import '../../../quick_login/data/quick_login_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double>   _fadeAnim;
  late Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );

    _animCtrl.forward();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // 애니메이션 시간 확보 (기존 유지)
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    // 1) 로컬 refresh 쿠키 없음 → 게스트 홈 (로그인 강제하려면 '/login')
    final hasRefresh = await CookieStore.hasRefreshToken();
    if (!hasRefresh) {
      if (mounted) context.go('/');
      return;
    }

    // 2) 간편인증 설정됨 → 서버 refresh 검증을 생략하고 바로 재인증 게이트로.
    //    세션 유효성 검증은 unlock 의 무음 refresh 에 위임한다.
    //    (스플래시에서 검증 후 unlock 에서 또 검증하면 로그인이 두 번 일어남)
    final quickEnabled = await QuickLoginService.instance.isAnyEnabled;
    if (quickEnabled) {
      if (mounted) context.go('/unlock');
      return;
    }

    // 3) 간편인증 미설정 → 서버 세션 검증 (#3 빈 회원 차단 / 서버 꺼지면 자동 로그아웃)
    final ok = await ref.read(authDatasourceProvider).refresh();
    if (!ok) {
      await ref.read(authStateProvider.notifier).onLogout();
      if (mounted) context.go('/login');
      return;
    }

    // 4) 세션 유효 → 로그인 상태 확정 후 홈
    await ref.read(authStateProvider.notifier).onLogin();
    if (mounted) context.go('/');
  }
  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.teal900,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: ScaleTransition(
            scale: _scaleAnim,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 로고 아이콘
                Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.credit_card,
                      size: 50,
                      color: AppColors.teal600,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'BNK 카드',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'BNK 부산은행',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 60),
                const SizedBox(
                  width: 24, height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}