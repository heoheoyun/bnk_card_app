import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:bnk_card_app/core/constants/app_colors.dart';
import 'package:bnk_card_app/shared/widgets/address_search_field.dart';
import 'package:bnk_card_app/shared/widgets/bnk_button.dart';
import '../providers/auth_provider.dart';
import '../providers/signup_draft_provider.dart';

/// 회원가입 1단계 폼.
/// 서버 SignupRequest 필수 필드(email/password/name/phone/residentFront/
/// genderCode/address)를 모두 수집하고, 입력값을 signupDraftProvider 에 저장한 뒤
/// 약관 동의 화면(/terms/SIGNUP)에서 agreedTermsIds 와 합쳐 최종 POST 한다.
class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _nameCtrl     = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _frontCtrl    = TextEditingController(); // 주민번호 앞 6
  final _genderCtrl   = TextEditingController(); // 성별코드 1
  final _postcodeCtrl = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _detailCtrl   = TextEditingController();

  bool _marketing = false;

  // 서버 @Pattern 과 동일한 클라이언트 검증
  static final _pwReg     = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,50}$');
  static final _phoneReg  = RegExp(r'^01[0-9]{8,9}$');   // 숫자만
  static final _frontReg  = RegExp(r'^[0-9]{6}$');
  static final _genderReg = RegExp(r'^[1-4789]$');       // 0,5,6 서버 거부

  @override
  void dispose() {
    for (final c in [
      _emailCtrl, _passwordCtrl, _nameCtrl, _phoneCtrl,
      _frontCtrl, _genderCtrl, _postcodeCtrl, _addressCtrl, _detailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String get _phoneDigits => _phoneCtrl.text.replaceAll(RegExp(r'\D'), '');

  String get _fullAddress => [_addressCtrl.text, _detailCtrl.text]
      .where((s) => s.trim().isNotEmpty)
      .join(' ');

  bool get _formValid =>
      _emailCtrl.text.contains('@') &&
          _pwReg.hasMatch(_passwordCtrl.text) &&
          _nameCtrl.text.trim().isNotEmpty &&
          _phoneReg.hasMatch(_phoneDigits) &&
          _frontReg.hasMatch(_frontCtrl.text) &&
          _genderReg.hasMatch(_genderCtrl.text) &&
          _fullAddress.isNotEmpty;

  /// 주민번호에서 생년월일(yyyy-MM-dd) 파생 (선택 필드 birthDate 용)
  String? _birthDate() {
    final f = _frontCtrl.text;
    final g = _genderCtrl.text;
    final century = switch (g) {
      '1' || '2' || '7' || '8' => 1900,
      '3' || '4' || '9'        => 2000, // 0은 서버 거부라 제외
      _ => null,
    };
    if (century == null || f.length != 6) return null;
    return '${century + int.parse(f.substring(0, 2))}'
        '-${f.substring(2, 4)}-${f.substring(4, 6)}';
  }

  Future<void> _sendVerifyCode() async {
    try {
      await ref
          .read(authRepositoryProvider)
          .sendVerifyCode(_emailCtrl.text.trim());
      // 인증 화면으로 이동하기 전, 이메일을 draft 에 저장
      ref.read(signupDraftProvider.notifier)
          .update((d) => d.copyWith(emailVerified: true));
      if (mounted) context.go('/signup/verify');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _goTerms() {
    // 입력값을 draft 에 저장 → 약관 페이지에서 agreedTermsIds 합쳐 POST
    ref.read(signupDraftProvider.notifier).update((d) => d.copyWith(
      email:          _emailCtrl.text.trim(),
      password:       _passwordCtrl.text,
      name:           _nameCtrl.text.trim(),
      phone:          _phoneDigits,
      residentFront:  _frontCtrl.text,
      genderCode:     _genderCtrl.text,
      address:        _fullAddress,
      birthDate:      _birthDate(),
      marketingAgree: _marketing,
    ));
    context.go('/terms/SIGNUP');
  }

  @override
  Widget build(BuildContext context) {
    // 인증 완료 여부는 draft 가 보유 (final 버그 제거)
    final verified = ref.watch(signupDraftProvider).emailVerified;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이메일 + 인증
        Row(children: [
          Expanded(
            child: TextField(
              controller:   _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              onChanged:    (_) => setState(() {}),
              decoration:   const InputDecoration(labelText: '이메일'),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: verified ? null : _sendVerifyCode,
            child: Text(verified ? '인증완료' : '인증'),
          ),
        ]),
        const SizedBox(height: 12),

        // 비밀번호
        TextField(
          controller: _passwordCtrl,
          obscureText: true,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText:  '비밀번호',
            helperText: '영문·숫자·특수문자 포함 8~50자',
          ),
        ),
        const SizedBox(height: 12),

        // 이름
        TextField(
          controller: _nameCtrl,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: '이름'),
        ),
        const SizedBox(height: 12),

        // 전화번호 (숫자만)
        TextField(
          controller:   _phoneCtrl,
          keyboardType: TextInputType.phone,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            labelText: '전화번호',
            hintText:  '01000000000 (숫자만)',
          ),
        ),
        const SizedBox(height: 12),

        // 주민번호 앞6 + 성별코드1
        const Text('주민등록번호',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Row(children: [
          Expanded(
            child: TextField(
              controller:   _frontCtrl,
              keyboardType: TextInputType.number,
              maxLength:    6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) {
                if (v.length == 6) FocusScope.of(context).nextFocus();
                setState(() {});
              },
              decoration: const InputDecoration(
                  hintText: '앞 6자리', counterText: ''),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text('-', style: TextStyle(fontSize: 16)),
          ),
          SizedBox(
            width: 44,
            child: TextField(
              controller:   _genderCtrl,
              keyboardType: TextInputType.number,
              maxLength:    1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(counterText: ''),
            ),
          ),
          const SizedBox(width: 4),
          const Text('●●●●●●',
              style: TextStyle(
                  fontSize: 16, color: AppColors.gray400, letterSpacing: 2)),
        ]),
        if (_genderCtrl.text.isNotEmpty &&
            !_genderReg.hasMatch(_genderCtrl.text))
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Text('온라인 가입이 불가한 성별코드입니다. 영업점을 방문해 주세요.',
                style: TextStyle(fontSize: 12, color: Colors.red)),
          ),
        const SizedBox(height: 12),

        // 주소 (Kakao 우편번호 검색 재사용)
        AddressSearchField(
          postcodeController: _postcodeCtrl,
          addressController:  _addressCtrl,
          detailController:   _detailCtrl,
          onChanged:          () => setState(() {}),
        ),
        const SizedBox(height: 8),

        // 마케팅 동의 (선택)
        CheckboxListTile(
          contentPadding:   EdgeInsets.zero,
          controlAffinity:  ListTileControlAffinity.leading,
          value:            _marketing,
          onChanged:        (v) => setState(() => _marketing = v ?? false),
          title: const Text('마케팅 정보 수신 동의 (선택)',
              style: TextStyle(fontSize: 13)),
        ),
        const SizedBox(height: 16),

        BnkButton(
          label: '약관 동의 후 가입하기',
          onPressed: (verified && _formValid) ? _goTerms : null,
        ),
      ],
    );
  }
}