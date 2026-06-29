// 마이페이지 > 간편로그인 설정.
//  - 생체인증 on/off (켤 때 1회 인증)
//  - 간편비밀번호(PIN) 설정/변경/해제
//  - 패턴 설정/변경/해제
//

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../quick_login/presentation/pages/pin_input_page.dart';
import '../../../quick_login/presentation/pages/pattern_input_page.dart';
import '../../../quick_login/presentation/providers/quick_login_provider.dart';

class QuickLoginSettingsPage extends ConsumerWidget {
  /// 첫 로그인 직후 온보딩으로 진입했는지 여부.
  /// true 면 '나중에 설정' 버튼을 노출하고, 설정완료/건너뛰기 시 홈('/')으로 이동한다.
  final bool onboarding;

  const QuickLoginSettingsPage({super.key, this.onboarding = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(quickLoginProvider);
    final notifier = ref.read(quickLoginProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BnkAppBar(
        title: '간편로그인 설정',
        // 온보딩 중엔 뒤로가기 대상을 홈으로 (마이페이지 스택이 없음)
        backPath: onboarding ? '/' : '/mypage',
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          _sectionHeader('간편 인증 수단'),

          // ── 생체인증 ──
          SwitchListTile(
            secondary: const Icon(Icons.fingerprint, color: AppColors.primary),
            title: Text(state.biometricLabel),
            subtitle: Text(state.biometricAvailable
                ? '지문 또는 얼굴로 빠르게 로그인합니다.'
                : '이 기기에서는 사용할 수 없습니다.'),
            value: state.biometricEnabled,
            onChanged: state.biometricAvailable
                ? (v) async {
                    final ok = await notifier.toggleBiometric(v);
                    if (context.mounted && v && !ok) {
                      _snack(context, '생체인증 등록에 실패했습니다.');
                    }
                  }
                : null,
          ),
          const Divider(height: 1),

          // ── PIN ──
          ListTile(
            leading: const Icon(Icons.dialpad, color: AppColors.primary),
            title: const Text('간편비밀번호(PIN)'),
            subtitle: Text(state.pinSet ? '설정됨' : '미설정'),
            trailing: Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => _setPin(context, notifier),
                  child: Text(state.pinSet ? '변경' : '설정'),
                ),
                if (state.pinSet)
                  TextButton(
                    onPressed: () => _confirmDisable(
                      context,
                      title: 'PIN 해제',
                      message: '간편비밀번호를 해제하시겠어요?',
                      onConfirm: notifier.disablePin,
                    ),
                    child: const Text('해제',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── 패턴 ──
          ListTile(
            leading: const Icon(Icons.pattern, color: AppColors.primary),
            title: const Text('패턴'),
            subtitle: Text(state.patternSet ? '설정됨' : '미설정'),
            trailing: Wrap(
              spacing: 4,
              children: [
                TextButton(
                  onPressed: () => _setPattern(context, notifier),
                  child: Text(state.patternSet ? '변경' : '설정'),
                ),
                if (state.patternSet)
                  TextButton(
                    onPressed: () => _confirmDisable(
                      context,
                      title: '패턴 해제',
                      message: '패턴을 해제하시겠어요?',
                      onConfirm: notifier.disablePattern,
                    ),
                    child: const Text('해제',
                        style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '간편로그인은 이 기기에서만 사용됩니다. 인증 5회 실패 시 자동 해제되며 '
              '비밀번호로 다시 로그인해야 합니다.',
              style: TextStyle(fontSize: 12, color: AppColors.gray400),
            ),
          ),
        ],
      ),
      bottomNavigationBar: onboarding ? _onboardingFooter(context, state) : null,
    );
  }

  /// 온보딩 진입 시 하단 버튼: 설정완료 / 나중에 설정 (둘 다 홈으로).
  Widget _onboardingFooter(BuildContext context, QuickLoginState state) {
    final anySet = state.biometricEnabled || state.pinSet || state.patternSet;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(anySet ? '설정 완료' : '시작하기',
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
          TextButton(
            onPressed: () => context.go('/'),
            child: const Text('나중에 설정',
                style: TextStyle(fontSize: 13, color: AppColors.gray600)),
          ),
        ],
      ),
    );
  }

  Future<void> _setPin(
      BuildContext context, QuickLoginNotifier notifier) async {
    final pin = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const PinInputPage()),
    );
    if (pin != null) {
      await notifier.setPin(pin);
      if (context.mounted) _snack(context, '간편비밀번호가 설정되었습니다.');
    }
  }

  Future<void> _setPattern(
      BuildContext context, QuickLoginNotifier notifier) async {
    final points = await Navigator.of(context).push<List<int>>(
      MaterialPageRoute(builder: (_) => const PatternInputPage()),
    );
    if (points != null) {
      await notifier.setPattern(points);
      if (context.mounted) _snack(context, '패턴이 설정되었습니다.');
    }
  }

  Future<void> _confirmDisable(
    BuildContext context, {
    required String title,
    required String message,
    required Future<void> Function() onConfirm,
  }) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('취소')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('해제', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) {
      await onConfirm();
      if (context.mounted) _snack(context, '$title되었습니다.');
    }
  }

  Widget _sectionHeader(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.gray400)),
      );

  void _snack(BuildContext context, String msg) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
}
