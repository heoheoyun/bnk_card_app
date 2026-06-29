// 앱 진입 잠금 화면(라우트 '/unlock').
//  - 생체인증이 켜져 있으면 진입 즉시 자동 시도
//  - PIN / 패턴이 있으면 입력 UI 표시 (둘 다면 전환 가능)
//  - 인증 성공 → access_token 무음 재발급(refresh) → 홈
//  - 5회 실패 / refresh 만료 → 비밀번호 전체 로그인('/login')
//
// 전제: 로그인 시 refresh_token 이 SecureStorage 에 저장돼 있어야 한다
//       (auth_remote_datasource.login() 의 토큰 저장 수정이 선행돼야 함).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/auth_state_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/quick_login_provider.dart';
import '../../data/quick_login_service.dart';
import '../widgets/pin_pad.dart';
import '../widgets/pattern_lock.dart';

class QuickLoginGatePage extends ConsumerStatefulWidget {
  const QuickLoginGatePage({super.key});

  @override
  ConsumerState<QuickLoginGatePage> createState() => _QuickLoginGatePageState();
}

class _QuickLoginGatePageState extends ConsumerState<QuickLoginGatePage> {
  QuickLoginService get _svc => ref.read(quickLoginServiceProvider);

  Set<QuickLoginMethod> _enabled = {};
  QuickLoginMethod? _active; // 현재 표시 중인 입력 수단
  String? _error;
  bool _busy = false;
  int _version = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    if (await _svc.isLocked()) {
      _toLogin('인증이 일시 제한되었습니다. 비밀번호로 로그인해 주세요.');
      return;
    }
    final methods = await _svc.enabledMethods();
    if (methods.isEmpty) {
      _toLogin(null);
      return;
    }
    setState(() {
      _enabled = methods;
      _active = methods.contains(QuickLoginMethod.pin)
          ? QuickLoginMethod.pin
          : methods.contains(QuickLoginMethod.pattern)
          ? QuickLoginMethod.pattern
          : QuickLoginMethod.biometric;
    });
    // 생체인증이 켜져 있으면 시도.
    // 콜드 스타트 직후엔 Activity resume 전이라 첫 호출이 즉시 실패하는
    // 안드로이드 이슈가 있어, 약간 지연 후 호출한다.
    if (methods.contains(QuickLoginMethod.biometric)) {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      _tryBiometric();
    }
  }

  Future<void> _tryBiometric() async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = await _svc.verifyBiometric();
    setState(() => _busy = false);
    await _handleResult(r);
  }

  Future<void> _onPin(String pin) async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = await _svc.verifyPin(pin);
    setState(() => _busy = false);
    await _handleResult(r);
  }

  Future<void> _onPattern(List<int> points) async {
    if (_busy) return;
    setState(() => _busy = true);
    final r = await _svc.verifyPattern(points);
    setState(() => _busy = false);
    await _handleResult(r);
  }

  Future<void> _handleResult(QuickAuthResult r) async {
    switch (r) {
      case QuickAuthResult.success:
        await _unlockAndEnter();
        break;
      case QuickAuthResult.wrong:
        final left = await _svc.remainingAttempts();
        setState(() {
          _error = '인증에 실패했습니다. (남은 시도 $left회)';
          _version++;
        });
        break;
      case QuickAuthResult.locked:
        _toLogin('5회 인증 실패로 간편로그인이 해제되었습니다. 비밀번호로 로그인해 주세요.');
        break;
      case QuickAuthResult.unavailable:
        _toLogin(null);
        break;
      case QuickAuthResult.canceled:
      // 취소/실패 → PIN·패턴 있으면 전환, 생체만 있으면 재시도 안내
        if (_enabled.contains(QuickLoginMethod.pin)) {
          setState(() => _active = QuickLoginMethod.pin);
        } else if (_enabled.contains(QuickLoginMethod.pattern)) {
          setState(() => _active = QuickLoginMethod.pattern);
        } else {
          setState(() => _error = '지문 아이콘을 눌러 다시 시도해 주세요.');
        }
        break;
    }
  }

  /// 간편 인증 통과 → access_token 무음 재발급 → 홈
  Future<void> _unlockAndEnter() async {
    setState(() => _busy = true);
    final ok = await ref.read(authDatasourceProvider).refresh();
    if (!mounted) return;
    if (ok) {
      ref.read(authStateProvider.notifier).onLogin();
      context.go('/');
    } else {
      // refresh 만료/실패 → 전체 로그인
      _toLogin('세션이 만료되었습니다. 다시 로그인해 주세요.');
    }
  }

  void _toLogin(String? message) {
    if (!mounted) return;
    if (message != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Column(
        children: [
          // ── 브랜드 헤더 (teal) ────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.teal900, AppColors.teal800],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.credit_card,
                          size: 30, color: AppColors.teal600),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'BNK 카드',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '간편인증으로 잠금을 해제하세요',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── 인증 영역 ─────────────────────────────────────────────
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 20,
                    child: Text(
                      _error ?? _hintFor(_active),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: _error != null ? Colors.red : AppColors.gray600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  _buildActive(),
                  const Spacer(),
                  _buildSwitcher(),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => _toLogin(null),
                    style: TextButton.styleFrom(
                        foregroundColor: AppColors.gray600),
                    child: const Text('비밀번호로 로그인'),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _hintFor(QuickLoginMethod? m) {
    switch (m) {
      case QuickLoginMethod.pin:
        return 'PIN을 입력해 주세요.';
      case QuickLoginMethod.pattern:
        return '패턴을 그려주세요.';
      case QuickLoginMethod.biometric:
        return '생체인증을 진행해 주세요.';
      default:
        return '';
    }
  }

  Widget _buildActive() {
    switch (_active) {
      case QuickLoginMethod.pin:
        return PinPad(
          key: ValueKey('pin_$_version'),
          onCompleted: _onPin,
          errorText: null,
        );
      case QuickLoginMethod.pattern:
        return Center(
          child: PatternLock(
            key: ValueKey('pat_$_version'),
            error: _error != null,
            onCompleted: _onPattern,
          ),
        );
      case QuickLoginMethod.biometric:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _busy ? null : _tryBiometric,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: AppColors.teal50,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.teal200, width: 1.5),
                  ),
                  child: _busy
                      ? const Padding(
                          padding: EdgeInsets.all(36),
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: AppColors.teal600),
                        )
                      : const Icon(Icons.fingerprint,
                          size: 56, color: AppColors.teal600),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _busy ? '인증 중…' : '지문/얼굴로 인증',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.gray600),
              ),
            ],
          ),
        );
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  /// 활성 수단이 2개 이상이면 전환 버튼 노출
  Widget _buildSwitcher() {
    final others =
        _enabled.where((m) => m != _active).toList(growable: false);
    if (others.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 10,
      children: others.map((m) {
        final (icon, label) = switch (m) {
          QuickLoginMethod.pin => (Icons.dialpad, 'PIN'),
          QuickLoginMethod.pattern => (Icons.pattern, '패턴'),
          QuickLoginMethod.biometric => (Icons.fingerprint, '생체'),
        };
        return OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _active = m;
              _error = null;
              _version++;
            });
            if (m == QuickLoginMethod.biometric) _tryBiometric();
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.teal600,
            side: const BorderSide(color: AppColors.teal200),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          ),
          icon: Icon(icon, size: 16),
          label: Text(label, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
    );
  }
}
