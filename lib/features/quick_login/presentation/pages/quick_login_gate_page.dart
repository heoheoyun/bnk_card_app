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
    // 생체인증이 켜져 있으면 즉시 시도
    if (methods.contains(QuickLoginMethod.biometric)) {
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
        // 생체인증 취소 → PIN/패턴이 있으면 그쪽으로, 없으면 대기
        if (_enabled.contains(QuickLoginMethod.pin)) {
          setState(() => _active = QuickLoginMethod.pin);
        } else if (_enabled.contains(QuickLoginMethod.pattern)) {
          setState(() => _active = QuickLoginMethod.pattern);
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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 48),
            const Icon(Icons.lock_outline, size: 40, color: AppColors.primary),
            const SizedBox(height: 16),
            const Text('간편로그인',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            SizedBox(
              height: 20,
              child: Text(
                _error ?? _hintFor(_active),
                style: TextStyle(
                  fontSize: 13,
                  color: _error != null ? Colors.red : AppColors.gray400,
                ),
              ),
            ),
            const Spacer(),
            _buildActive(),
            const Spacer(),
            _buildSwitcher(),
            TextButton(
              onPressed: () => _toLogin(null),
              child: const Text('비밀번호로 로그인'),
            ),
            const SizedBox(height: 12),
          ],
        ),
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
          child: IconButton(
            iconSize: 72,
            icon: const Icon(Icons.fingerprint, color: AppColors.primary),
            onPressed: _busy ? null : _tryBiometric,
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
      spacing: 12,
      children: others.map((m) {
        final (icon, label) = switch (m) {
          QuickLoginMethod.pin => (Icons.dialpad, 'PIN'),
          QuickLoginMethod.pattern => (Icons.pattern, '패턴'),
          QuickLoginMethod.biometric => (Icons.fingerprint, '생체'),
        };
        return TextButton.icon(
          onPressed: () {
            setState(() {
              _active = m;
              _error = null;
              _version++;
            });
            if (m == QuickLoginMethod.biometric) _tryBiometric();
          },
          icon: Icon(icon, size: 18),
          label: Text(label),
        );
      }).toList(),
    );
  }
}
