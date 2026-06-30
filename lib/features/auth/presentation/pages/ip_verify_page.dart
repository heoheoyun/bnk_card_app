// IP 2단계 인증 화면 (이메일 코드 / CI).
// 로그인 응답이 requireIpVerify=true 일 때 '/ip-verify' 로 진입.
// availableMethods 에 EMAIL / CI 가 내려오며, 둘 다 있으면 사용자가 방식을 고른다.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../../../core/providers/auth_state_provider.dart'; // authStateProvider 위치에 맞게 경로 확인

class IpVerifyArgs {
  final int userId;
  final String challengeToken;
  final List<String> methods;
  const IpVerifyArgs({
    required this.userId,
    required this.challengeToken,
    required this.methods,
  });
}

class IpVerifyPage extends ConsumerStatefulWidget {
  final IpVerifyArgs args;
  const IpVerifyPage({super.key, required this.args});

  @override
  ConsumerState<IpVerifyPage> createState() => _IpVerifyPageState();
}

class _IpVerifyPageState extends ConsumerState<IpVerifyPage> {
  // 이메일 방식
  final _codeCtrl = TextEditingController();
  bool _sent = false;
  // CI 방식
  final _nameCtrl = TextEditingController();
  final _residentCtrl = TextEditingController(); // 주민번호 앞 6자리(생년월일)
  final _phoneCtrl = TextEditingController();

  late String _method; // 'EMAIL' | 'CI'
  bool _busy = false;

  bool get _hasEmail => widget.args.methods.contains('EMAIL');
  bool get _hasCi => widget.args.methods.contains('CI');

  @override
  void initState() {
    super.initState();
    // 가능한 방식 중 이메일을 기본값으로(둘 다 없으면 첫 항목).
    _method = _hasEmail ? 'EMAIL' : (widget.args.methods.isNotEmpty ? widget.args.methods.first : 'EMAIL');
    if (_method == 'EMAIL') {
      WidgetsBinding.instance.addPostFrameCallback((_) => _sendCode());
    }
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    _residentCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _switchMethod(String m) {
    if (_method == m || _busy) return;
    setState(() => _method = m);
    // 이메일로 전환했고 아직 코드를 안 보냈으면 1회 발송
    if (m == 'EMAIL' && !_sent) _sendCode();
  }

  Future<void> _sendCode() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).sendIpEmailCode(
        userId: widget.args.userId,
        challengeToken: widget.args.challengeToken,
      );
      if (!mounted) return;
      setState(() => _sent = true);
      _snack('인증 코드를 이메일로 보냈습니다. (10분 유효)');
    } catch (_) {
      _snack('인증 코드 발송에 실패했습니다. 다시 시도해 주세요.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmEmail() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      _snack('인증 코드를 입력해 주세요.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).confirmIpEmailCode(
        userId: widget.args.userId,
        challengeToken: widget.args.challengeToken,
        code: code,
        nickname: '내 기기',
      );
      _onAuthSuccess();
    } catch (_) {
      if (!mounted) return;
      _snack('인증에 실패했습니다. 코드를 확인해 주세요.');
      setState(() => _busy = false);
    }
  }

  Future<void> _confirmCi() async {
    final name = _nameCtrl.text.trim();
    final resident = _residentCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = _phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (name.isEmpty || resident.length != 6 || phone.length < 9) {
      _snack('이름, 생년월일 6자리, 전화번호를 정확히 입력해 주세요.');
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(authProvider.notifier).verifyIpCi(
        userId: widget.args.userId,
        challengeToken: widget.args.challengeToken,
        name: name,
        residentFront: resident,
        phone: phone,
        nickname: '내 기기',
      );
      _onAuthSuccess();
    } catch (_) {
      if (!mounted) return;
      _snack('본인확인에 실패했습니다. 입력 정보를 확인해 주세요.');
      setState(() => _busy = false);
    }
  }

  void _onAuthSuccess() {
    if (!mounted) return;
    // 전역 로그인 상태를 켜고(awaiting 없이) 곧바로 이동한다.
    // onLogin() 내부의 FCM 토큰 등록은 백그라운드로 진행되므로 화면 전환을 막지 않는다.
    ref.read(authStateProvider.notifier).onLogin();
    context.go('/');
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    final showToggle = _hasEmail && _hasCi;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.gray800,
        title: const Text('기기 인증', style: TextStyle(fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 20),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              const Icon(Icons.shield_outlined,
                  size: 40, color: AppColors.teal600),
              const SizedBox(height: 16),
              const Text('새로운 기기에서 로그인했어요',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                _method == 'EMAIL'
                    ? '안전을 위해 가입하신 이메일로 보낸 인증 코드를 입력해 주세요.'
                    : '안전을 위해 본인확인 정보(이름·생년월일·전화번호)를 입력해 주세요.',
                style: const TextStyle(fontSize: 13, color: AppColors.gray600),
              ),
              const SizedBox(height: 24),

              if (showToggle) ...[
                _MethodToggle(
                  method: _method,
                  busy: _busy,
                  onChanged: _switchMethod,
                ),
                const SizedBox(height: 24),
              ],

              if (_method == 'EMAIL') _buildEmailForm() else _buildCiForm(),

              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('다른 계정으로 로그인',
                      style: TextStyle(fontSize: 12, color: AppColors.gray600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('인증 코드',
            style: TextStyle(fontSize: 12, color: AppColors.gray600)),
        const SizedBox(height: 6),
        TextField(
          controller: _codeCtrl,
          textCapitalization: TextCapitalization.characters,
          onSubmitted: (_) => _confirmEmail(),
          decoration: _dec('6자리 코드'),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _busy ? null : _sendCode,
            child: Text(_sent ? '코드 재전송' : '코드 받기',
                style: const TextStyle(fontSize: 12, color: AppColors.teal600)),
          ),
        ),
        const SizedBox(height: 16),
        _submitButton('인증하고 로그인', _confirmEmail),
      ],
    );
  }

  Widget _buildCiForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이름',
            style: TextStyle(fontSize: 12, color: AppColors.gray600)),
        const SizedBox(height: 6),
        TextField(controller: _nameCtrl, decoration: _dec('홍길동')),
        const SizedBox(height: 16),
        const Text('생년월일 (주민번호 앞 6자리)',
            style: TextStyle(fontSize: 12, color: AppColors.gray600)),
        const SizedBox(height: 6),
        TextField(
          controller: _residentCtrl,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: _dec('YYMMDD'),
        ),
        const SizedBox(height: 16),
        const Text('전화번호',
            style: TextStyle(fontSize: 12, color: AppColors.gray600)),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onSubmitted: (_) => _confirmCi(),
          decoration: _dec('-없이 숫자만'),
        ),
        const SizedBox(height: 24),
        _submitButton('본인확인하고 로그인', _confirmCi),
      ],
    );
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.gray200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.teal600),
        ),
      );

  Widget _submitButton(String label, VoidCallback onPressed) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _busy ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500)),
        ),
      );
}

class _MethodToggle extends StatelessWidget {
  final String method;
  final bool busy;
  final ValueChanged<String> onChanged;
  const _MethodToggle({
    required this.method,
    required this.busy,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _tab('이메일 인증', 'EMAIL'),
          _tab('본인확인(CI)', 'CI'),
        ],
      ),
    );
  }

  Widget _tab(String label, String value) {
    final selected = method == value;
    return Expanded(
      child: GestureDetector(
        onTap: busy ? null : () => onChanged(value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: selected
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.teal600 : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }
}
