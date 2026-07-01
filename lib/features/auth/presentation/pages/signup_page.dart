import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/signup_request_model.dart';
import '../providers/auth_provider.dart';
import '../../../terms/presentation/providers/terms_provider.dart';
import 'package:bnk_card_app/shared/widgets/kakao_address_search_page.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  int _step = 0;

  bool _agreeAll       = false;
  bool _agreeRequired1 = false;
  bool _agreeRequired2 = false;
  bool _agreeMarketing = false;

  final _emailCtrl         = TextEditingController();
  final _codeCtrl          = TextEditingController();
  final _pwCtrl            = TextEditingController();
  final _pwConfirmCtrl     = TextEditingController();
  final _nameCtrl          = TextEditingController();
  final _phoneCtrl         = TextEditingController();
  final _residentFrontCtrl = TextEditingController();
  final _genderCodeCtrl    = TextEditingController();
  final _addressCtrl       = TextEditingController();
  final _postcodeCtrl   = TextEditingController(); // 우편번호
  final _addrDetailCtrl = TextEditingController(); // 상세주소

  bool _obscurePw        = true;
  bool _obscurePwConfirm = true;
  bool _emailVerified    = false;
  bool _isSendingCode    = false;
  bool _isVerifyingCode  = false;
  bool _isSubmitting     = false;

  String? _selectedJob;
  String? _selectedIncome;

  static const _jobs    = ['직장인', '자영업자', '학생', '주부', '무직', '기타'];
  static const _incomes = ['2천만원 미만', '2천~4천만원', '4천~6천만원', '6천~8천만원', '8천만원 이상'];

  bool get _pwLengthOk  => _pwCtrl.text.length >= 8 && _pwCtrl.text.length <= 50;
  bool get _pwUpperOk   => _pwCtrl.text.contains(RegExp(r'[A-Za-z]'));
  bool get _pwNumOk     => _pwCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _pwSpecialOk => _pwCtrl.text.contains(RegExp(r'[@$!%*#?&]'));
  bool get _pwValid     => _pwLengthOk && _pwUpperOk && _pwNumOk && _pwSpecialOk;

  @override
  void dispose() {
    _emailCtrl.dispose(); _codeCtrl.dispose();
    _pwCtrl.dispose(); _pwConfirmCtrl.dispose();
    _nameCtrl.dispose(); _phoneCtrl.dispose();
    _residentFrontCtrl.dispose();
    _genderCodeCtrl.dispose();
    _addressCtrl.dispose();
    _postcodeCtrl.dispose();
    _addrDetailCtrl.dispose();
    super.dispose();
  }

  void _updateAgreeAll() => setState(() =>
  _agreeAll = _agreeRequired1 && _agreeRequired2 && _agreeMarketing);

  void _toggleAll(bool? val) {
    final v = val ?? false;
    setState(() {
      _agreeAll       = v;
      _agreeRequired1 = v;
      _agreeRequired2 = v;
      _agreeMarketing = v;
    });
  }

  Future<void> _sendCode() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _isSendingCode = true);
    try {
      await ref.read(authRepositoryProvider).sendVerifyCode(_emailCtrl.text.trim());
      if (mounted) _snack('인증코드를 발송했습니다. 메일의 코드를 입력해주세요.');
    } catch (_) {
      if (mounted) _snack('인증코드 발송에 실패했습니다.');
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  Future<void> _verifyCode() async {
    if (_codeCtrl.text.trim().isEmpty) return;
    setState(() => _isVerifyingCode = true);
    try {
      await ref.read(authRepositoryProvider)
          .verifyEmail(_emailCtrl.text.trim(), _codeCtrl.text.trim());
      setState(() => _emailVerified = true);
      if (mounted) _snack('이메일 인증이 완료되었습니다.');
    } catch (_) {
      if (mounted) _snack('인증코드가 올바르지 않습니다.');
    } finally {
      if (mounted) setState(() => _isVerifyingCode = false);
    }
  }

  Future<void> _searchAddress() async {
    FocusScope.of(context).unfocus();
    final result = await Navigator.of(context).push<KakaoAddress>(
      MaterialPageRoute(builder: (_) => const KakaoAddressSearchPage()),
    );
    if (result != null && mounted) {
      setState(() {
        _postcodeCtrl.text = result.zonecode;
        _addressCtrl.text  = result.address; // 도로명 우선
      });
    }
  }

  /// 주민번호 앞 6자리(YYMMDD) + 성별코드 → 생년월일(yyyy-MM-dd) 유도.
  /// 웹 본인인증 모달(identity-verify.js)과 동일한 규칙.
  String? _deriveBirthDate(String residentFront, String genderCode) {
    if (residentFront.length != 6 || genderCode.isEmpty) return null;
    final century = ['3', '4', '7', '8'].contains(genderCode) ? '20' : '19';
    return '$century${residentFront.substring(0, 2)}-'
        '${residentFront.substring(2, 4)}-'
        '${residentFront.substring(4, 6)}';
  }

  Future<void> _submit() async {
    if (!_emailVerified) { _snack('이메일 인증을 완료해주세요.'); return; }
    if (!_pwValid)       { _snack('비밀번호 조건을 확인해주세요.'); return; }
    if (_pwCtrl.text != _pwConfirmCtrl.text) { _snack('비밀번호가 일치하지 않습니다.'); return; }
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      _snack('이름과 휴대폰 번호를 입력해주세요.'); return;
    }
    if (_residentFrontCtrl.text.trim().length != 6) {
      _snack('주민번호 앞 6자리를 입력해주세요.'); return;
    }
    if (_genderCodeCtrl.text.trim().isEmpty) {
      _snack('성별코드를 입력해주세요.'); return;
    }
    if (_addressCtrl.text.trim().isEmpty) {
      _snack('주소를 입력해주세요.'); return;
    }

    setState(() => _isSubmitting = true);

    try {
      // 약관 ID를 직접 API 호출로 가져오기 (캐시 타이밍 문제 방지)
      final ds = ref.read(termsDatasourceProvider);
      final termsList = await ds.getTermsPackage('SIGNUP');
      final agreedTermsIds = <int>[];
      for (final t in termsList) {
        final m        = Map<String, dynamic>.from(t as Map);
        final required = m['requiredYn'] as String? ?? 'N';
        final termsId  = (m['termsId'] as num?)?.toInt();
        if (termsId == null) continue;
        if (required == 'Y' || _agreeMarketing) agreedTermsIds.add(termsId);
      }

      if (agreedTermsIds.isEmpty) {
        _snack('약관 정보를 불러오지 못했습니다. 다시 시도해주세요.');
        setState(() => _isSubmitting = false);
        return;
      }

      final residentFront = _residentFrontCtrl.text.trim();
      final genderCode    = _genderCodeCtrl.text.trim();

      final req = SignupRequestModel(
        email:           _emailCtrl.text.trim(),
        password:        _pwCtrl.text,
        name:            _nameCtrl.text.trim(),
        phone:           _phoneCtrl.text.trim(),
        agreedTermsIds:  agreedTermsIds,
        residentFront:   residentFront,
        genderCode:      genderCode,
        address: [_addressCtrl.text.trim(), _addrDetailCtrl.text.trim()]
            .where((s) => s.isNotEmpty)
            .join(' '),
        birthDate:       _deriveBirthDate(residentFront, genderCode),
        marketingAgree:  _agreeMarketing,
        job:             _selectedJob,
        incomeLevelCode: _selectedIncome,
        creditScore:     null,
      );

      await ref.read(authProvider.notifier).signup(req);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입이 완료되었습니다. 로그인해주세요.'),
            duration: Duration(seconds: 3),
          ),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) context.go('/login');
      }
    } catch (e) {
      final msg = e.toString().contains('409') ? '이미 가입된 이메일입니다.'
          : e.toString().contains('400') ? '입력 정보를 확인해주세요.'
          : '회원가입에 실패했습니다. 다시 시도해주세요.';
      _snack(msg);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
    filled: true,
    fillColor: AppColors.gray100,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.teal600, width: 1.2)),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // 회원정보 입력(step1)에서 뒤로가기 → 약관동의(step0)로, 약관(step0)에서는 페이지 pop.
      canPop: _step == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        setState(() => _step = 0);
      },
      child: Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.gray800,
        title: const Text('회원가입',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _dot(0, '약관동의'),
                  _line(_step >= 1),
                  _dot(1, '회원정보 입력'),
                  _line(_step >= 2),
                  _dot(2, '가입완료'),
                ],
              ),
            ),
            Expanded(
              child: _step == 0 ? _termsStep() : _infoStep(),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _dot(int index, String label) {
    final isActive = _step == index;
    final isDone   = _step > index;
    return Column(
      children: [
        Container(
          width: 26, height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive || isDone ? AppColors.teal600 : AppColors.gray200,
          ),
          child: Center(
            child: isDone
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : Text('${index + 1}', style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: isActive ? Colors.white : AppColors.gray400)),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(
            fontSize: 10,
            color: isActive ? AppColors.teal600 : AppColors.gray400)),
      ],
    );
  }

  Widget _line(bool active) => Container(
    width: 36, height: 1.5,
    margin: const EdgeInsets.only(bottom: 18),
    color: active ? AppColors.teal600 : AppColors.gray200,
  );

  // ── 1단계: 약관동의 ──────────────────────────────────────────
  Widget _termsStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.teal50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CheckboxListTile(
                  value: _agreeAll,
                  onChanged: _toggleAll,
                  activeColor: AppColors.teal600,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('전체 약관에 동의합니다',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  subtitle: const Text('필수·선택 포함',
                      style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                ),
              ),
              const SizedBox(height: 12),
              _termsItem(
                title: '홈페이지 회원약관', isRequired: true, value: _agreeRequired1,
                onChanged: (v) { setState(() => _agreeRequired1 = v ?? false); _updateAgreeAll(); },
                content: '제1조(목적) 이 약관은 주식회사 부산은행(이하 "은행"이라 한다)과 이용 고객간에 홈페이지의 이용조건 및 절차에 관한 사항을 정함을 목적으로 합니다. 이 약관은 부산은행 웹사이트에서 온라인으로 공시함으로써 효력을 발생합니다.',
              ),
              const SizedBox(height: 8),
              _termsItem(
                title: '개인정보처리방침', isRequired: true, value: _agreeRequired2,
                onChanged: (v) { setState(() => _agreeRequired2 = v ?? false); _updateAgreeAll(); },
                content: '(주)부산은행은 개인정보보호법 제30조에 따라 고객의 개인정보 보호 및 권익을 보호하고 개인정보와 관련한 고객의 고충을 원활하게 처리할 수 있도록 다음과 같은 처리방침을 두고 있습니다.',
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.gray200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: CheckboxListTile(
                  value: _agreeMarketing,
                  onChanged: (v) { setState(() => _agreeMarketing = v ?? false); _updateAgreeAll(); },
                  activeColor: AppColors.teal600,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('마케팅 정보 수신에 동의합니다',
                      style: TextStyle(fontSize: 13)),
                  subtitle: const Text('선택',
                      style: TextStyle(fontSize: 11, color: AppColors.gray400)),
                ),
              ),
            ],
          ),
        ),
        _bottomBar(
          onCancel: () => context.go('/login'),
          onNext: () {
            if (!_agreeRequired1 || !_agreeRequired2) {
              _snack('필수 약관에 동의해주세요.'); return;
            }
            setState(() => _step = 1);
          },
          nextLabel: '다음',
        ),
      ],
    );
  }

  Widget _termsItem({
    required String title, required bool isRequired,
    required bool value, required ValueChanged<bool?> onChanged,
    required String content,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.gray200),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Checkbox(value: value, onChanged: onChanged, activeColor: AppColors.teal600),
                Expanded(child: Text(title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isRequired ? AppColors.teal50 : AppColors.gray100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(isRequired ? '필수' : '선택',
                      style: TextStyle(fontSize: 10,
                          color: isRequired ? AppColors.teal800 : AppColors.gray600)),
                ),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            padding: const EdgeInsets.all(10),
            height: 90,
            decoration: BoxDecoration(
                color: AppColors.gray100, borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: Text(content,
                  style: const TextStyle(fontSize: 11, color: AppColors.gray600, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  // ── 2단계: 회원정보 입력 ────────────────────────────────────
  Widget _infoStep() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            children: [
              // 이메일 인증
              _secTitle('이메일 인증'),
              _lbl('이메일 *'),
              TextField(
                controller: _emailCtrl,
                enabled: !_emailVerified,
                keyboardType: TextInputType.emailAddress,
                decoration: _dec('이메일 주소를 입력하세요'),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _emailVerified || _isSendingCode ? null : _sendCode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal600,
                    side: const BorderSide(color: AppColors.teal600),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isSendingCode
                      ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal600))
                      : const Text('인증코드 발송'),
                ),
              ),
              const SizedBox(height: 4),
              const Text('간혹 인증코드가 스팸에 도착할 수 있습니다.',
                  style: TextStyle(fontSize: 11, color: AppColors.gray400)),
              const SizedBox(height: 12),
              _lbl('이메일 인증코드 *'),
              TextField(
                controller: _codeCtrl,
                enabled: !_emailVerified,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: _dec('6자리 코드 입력').copyWith(counterText: ''),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _emailVerified || _isVerifyingCode ? null : _verifyCode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _emailVerified ? AppColors.gray400 : AppColors.teal600,
                    side: BorderSide(
                        color: _emailVerified ? AppColors.gray400 : AppColors.teal600),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isVerifyingCode
                      ? const SizedBox(width: 16, height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_emailVerified ? '인증완료' : '인증코드 확인'),
                ),
              ),
              const SizedBox(height: 20),

              // 비밀번호 설정
              _secTitle('비밀번호 설정'),
              _lbl('비밀번호 *'),
              TextField(
                controller: _pwCtrl,
                obscureText: _obscurePw,
                onChanged: (_) => setState(() {}),
                decoration: _dec('영문, 숫자, 특수문자 포함 8자 이상').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePw
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                        size: 18, color: AppColors.gray400),
                    onPressed: () => setState(() => _obscurePw = !_obscurePw),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              _pwRow('8자 이상 50자 이하', _pwLengthOk),
              _pwRow('영문 포함', _pwUpperOk),
              _pwRow('숫자 포함', _pwNumOk),
              _pwRow('특수문자 포함 (@\$!%*#?&)', _pwSpecialOk),
              const SizedBox(height: 12),
              _lbl('비밀번호 확인 *'),
              TextField(
                controller: _pwConfirmCtrl,
                obscureText: _obscurePwConfirm,
                onChanged: (_) => setState(() {}),
                decoration: _dec('비밀번호를 다시 입력하세요').copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePwConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                        size: 18, color: AppColors.gray400),
                    onPressed: () => setState(() => _obscurePwConfirm = !_obscurePwConfirm),
                  ),
                ),
              ),
              if (_pwConfirmCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      _pwCtrl.text == _pwConfirmCtrl.text
                          ? Icons.check_circle
                          : Icons.cancel,
                      size: 14,
                      color: _pwCtrl.text == _pwConfirmCtrl.text
                          ? AppColors.teal600
                          : Colors.red,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _pwCtrl.text == _pwConfirmCtrl.text
                          ? '비밀번호가 일치합니다'
                          : '비밀번호가 일치하지 않습니다',
                      style: TextStyle(
                        fontSize: 11,
                        color: _pwCtrl.text == _pwConfirmCtrl.text
                            ? AppColors.teal600
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              // 기본 정보
              _secTitle('기본 정보'),
              _lbl('이름 *'),
              TextField(controller: _nameCtrl, decoration: _dec('홍길동')),
              const SizedBox(height: 12),
              _lbl('휴대폰 번호 *'),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: _dec("'-' 없이 숫자만 입력"),
              ),
              const SizedBox(height: 12),
              const SizedBox(height: 20),

              // 본인 확인 정보 (CI 생성용)
              // 본인 확인 정보
              _secTitle('본인 확인 정보'),
              _lbl('주민등록번호 *'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _residentFrontCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      decoration: _dec('앞 6자리').copyWith(counterText: ''),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('-', style: TextStyle(fontSize: 20, color: AppColors.gray600)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _genderCodeCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      obscureText: true,
                      decoration: _dec('●●●●●●').copyWith(counterText: ''),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _lbl('주소 *'),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _postcodeCtrl,
                      readOnly: true,
                      decoration: _dec('우편번호'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    height: 48,
                    width: 90,
                    child: OutlinedButton(
                      onPressed: _searchAddress,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.teal600,
                        side: const BorderSide(color: AppColors.teal600),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('주소 검색'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressCtrl,
                readOnly: true,            // 직접 입력 막고 검색으로만 채움
                onTap: _searchAddress,
                decoration: _dec('도로명 주소 (주소 검색 버튼)'),
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addrDetailCtrl,
                decoration: _dec('상세주소 (동·호수 등)'),
              ),
              const SizedBox(height: 20),

              // 추가 정보 (선택)
              _secTitle('추가 정보', optional: true),
              _lbl('직업'),
              DropdownButtonFormField<String>(
                initialValue: _selectedJob,
                hint: const Text('선택하지 않음',
                    style: TextStyle(fontSize: 13, color: AppColors.gray400)),
                decoration: InputDecoration(
                  filled: true, fillColor: AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                items: _jobs.map((j) => DropdownMenuItem(value: j, child: Text(j))).toList(),
                onChanged: (v) => setState(() => _selectedJob = v),
              ),
              const SizedBox(height: 12),
              _lbl('소득 등급'),
              DropdownButtonFormField<String>(
                initialValue: _selectedIncome,
                hint: const Text('선택하지 않음',
                    style: TextStyle(fontSize: 13, color: AppColors.gray400)),
                decoration: InputDecoration(
                  filled: true, fillColor: AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
                items: _incomes.map((i) => DropdownMenuItem(value: i, child: Text(i))).toList(),
                onChanged: (v) => setState(() => _selectedIncome = v),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        _bottomBar(
          onCancel: () => setState(() => _step = 0),
          onNext: _isSubmitting ? null : _submit,
          nextLabel: _isSubmitting ? '처리중...' : '가입하기',
        ),
      ],
    );
  }

  Widget _secTitle(String title, {bool optional = false}) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      children: [
        Text(title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.teal600)),
        if (optional) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
                color: AppColors.gray100, borderRadius: BorderRadius.circular(4)),
            child: const Text('선택',
                style: TextStyle(fontSize: 10, color: AppColors.gray600)),
          ),
        ],
      ],
    ),
  );

  Widget _lbl(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.gray600)),
  );

  Widget _pwRow(String label, bool ok) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(ok ? Icons.check_circle : Icons.cancel, size: 14,
            color: _pwCtrl.text.isEmpty ? AppColors.gray400
                : (ok ? AppColors.teal600 : Colors.red)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11,
            color: _pwCtrl.text.isEmpty ? AppColors.gray400
                : (ok ? AppColors.teal600 : Colors.red))),
      ],
    ),
  );

  Widget _bottomBar({
    required VoidCallback? onCancel,
    required VoidCallback? onNext,
    required String nextLabel,
  }) => Container(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: AppColors.gray200, width: 0.5)),
    ),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.gray600,
              side: const BorderSide(color: AppColors.gray200),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('이전', style: TextStyle(fontSize: 14)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: onNext,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(nextLabel,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    ),
  );
}