import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../domain/entities/credit_application.dart';
import '../../../presentation/providers/credit_application_provider.dart';
import '../../../presentation/providers/account_provider.dart';
import '../../../presentation/widgets/application_step_indicator.dart';
import 'package:bnk_card_app/shared/widgets/address_search_field.dart';

class CreditStep3ApplicantPage extends ConsumerStatefulWidget {
  final int cardId;
  const CreditStep3ApplicantPage({super.key, required this.cardId});

  @override
  ConsumerState<CreditStep3ApplicantPage> createState() =>
      _CreditStep3ApplicantPageState();
}

class _CreditStep3ApplicantPageState
    extends ConsumerState<CreditStep3ApplicantPage> {

  final _nameCtrl    = TextEditingController();
  final _nameEnCtrl  = TextEditingController();
  final _mobileCtrl  = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _postcodeCtrl   = TextEditingController();
  final _addrDetailCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();

  String? _incomeType;
  String? _healthInsuranceType;
  String  _hasRealEstate = 'N';
  String  _hasOwnVehicle = 'N';
  String? _annualIncomeBand;
  String? _creditScoreBand;
  int?    _linkedAccountId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final appState = ref.read(creditApplicationProvider);
      final draft    = appState.draftApplicantSnapshot;
      if (draft == null) return;

      setState(() {
        _nameCtrl.text    = draft.name;
        _nameEnCtrl.text  = draft.nameEn ?? '';
        _mobileCtrl.text  = draft.mobileNo;
        _addressCtrl.text = draft.address;
        _emailCtrl.text   = draft.email;
        _incomeType          = draft.incomeType;
        _healthInsuranceType = draft.healthInsuranceType;
        _hasRealEstate       = draft.hasRealEstate ?? 'N';
        _hasOwnVehicle       = draft.hasOwnVehicle ?? 'N';
        _annualIncomeBand    = appState.draftAnnualIncomeBand;
        _creditScoreBand     = appState.draftCreditScoreBand;
        _linkedAccountId     = appState.draftLinkedAccountId;
      });
    });
  }


  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameEnCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _postcodeCtrl.dispose();
    _addrDetailCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _canNext =>
      _nameCtrl.text.isNotEmpty &&
          _mobileCtrl.text.isNotEmpty &&
          _addressCtrl.text.isNotEmpty &&
          _emailCtrl.text.isNotEmpty &&
          _incomeType != null &&
          _healthInsuranceType != null &&
          _annualIncomeBand != null &&
          _creditScoreBand != null &&
          _linkedAccountId != null;

  @override
  Widget build(BuildContext context) {
    final appState     = ref.watch(creditApplicationProvider);
    final appNotifier  = ref.read(creditApplicationProvider.notifier);
    final accountAsync = ref.watch(myAccountsProvider);

    return Scaffold(
      appBar: const BnkAppBar(title: '카드 신청', showBack: false),
      body: Column(
        children: [
          ApplicationStepIndicator(currentStep: 3, totalSteps: 5),

          Expanded(
            child: accountAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (_, __) => const Center(child: Text('계좌 정보를 불러오지 못했습니다.')),
              data: (accounts) {
                // 계좌 없으면 계좌개설 페이지로 이동
                if (accounts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '연결할 계좌가 없습니다.',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '카드 신청을 위해 계좌를 먼저 개설해 주세요.',
                          style: TextStyle(fontSize: 13, color: AppColors.gray600),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.teal600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => context.push('/accounts/create'),
                          child: const Text('계좌 개설하기'),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '기본정보',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),

                      // 이름
                      _Field(label: '이름', controller: _nameCtrl,
                          hint: '이름을 입력해 주세요', onChanged: (_) => setState(() {})),
                      const SizedBox(height: 16),

                      // 영문 이름
                      _Field(label: '영문 이름', controller: _nameEnCtrl,
                          hint: 'HONG GILDONG', onChanged: (_) => setState(() {})),
                      const SizedBox(height: 16),

                      // 휴대폰 번호
                      _Field(label: '휴대폰 번호', controller: _mobileCtrl,
                          hint: '-없이 숫자만 입력',
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => setState(() {})),
                      const SizedBox(height: 16),

                      // 주소
                      AddressSearchField(
                        postcodeController: _postcodeCtrl,
                        addressController:  _addressCtrl,
                        detailController:   _addrDetailCtrl,
                        onChanged: () => setState(() {}),
                      ),

                      // 이메일
                      _Field(label: '이메일', controller: _emailCtrl,
                          hint: 'example@email.com',
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (_) => setState(() {})),
                      const SizedBox(height: 24),

                      const Text(
                        '직업/소득 정보',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 16),

                      // 직업 구분
                      _Dropdown(
                        label: '직업 구분',
                        value: _incomeType,
                        items: const {
                          'EMPLOYED':      '직장인',
                          'SELF_EMPLOYED': '자영업자',
                          'STUDENT':       '학생',
                          'UNEMPLOYED':    '무직/전업주부',
                          'OTHER':         '기타',
                        },
                        onChanged: (v) => setState(() => _incomeType = v),
                      ),
                      const SizedBox(height: 16),

                      // 건강보험 유형
                      _Dropdown(
                        label: '건강보험 유형',
                        value: _healthInsuranceType,
                        items: const {
                          'EMPLOYEE':  '직장가입자',  // 직장인, 공무원
                          'REGIONAL':  '지역가입자',  // 자영업자, 프리랜서, 무직
                          'DEPENDENT': '피부양자',    // 배우자/부모 등 가족 직장보험에 올라간 경우
                        },
                        onChanged: (v) => setState(() => _healthInsuranceType = v),
                      ),
                      const SizedBox(height: 16),

                      // 연소득 구간
                      _Dropdown(
                        label: '연소득 구간',
                        value: _annualIncomeBand,
                        items: const {
                          'LV1': '2천만원 미만',
                          'LV2': '2천만원 ~ 5천만원',
                          'LV3': '5천만원 ~ 1억원',
                          'LV4': '1억원 이상',
                        },
                        onChanged: (v) => setState(() => _annualIncomeBand = v),
                      ),
                      const SizedBox(height: 16),

                      // 신용점수 구간
                      _Dropdown(
                        label: '신용점수 구간',
                        value: _creditScoreBand,
                        items: const {
                          'HIGH': '800점 이상',
                          'MID':  '600점 ~ 800점',
                          'LOW':  '600점 이하',
                        },
                        onChanged: (v) => setState(() => _creditScoreBand = v),
                      ),
                      const SizedBox(height: 16),

                      // 부동산 보유
                      _YNToggle(
                        label:    '부동산 보유 여부',
                        value:    _hasRealEstate,
                        onChanged: (v) => setState(() => _hasRealEstate = v),
                      ),
                      const SizedBox(height: 16),

                      // 자차 보유
                      _YNToggle(
                        label:    '자차 보유 여부',
                        value:    _hasOwnVehicle,
                        onChanged: (v) => setState(() => _hasOwnVehicle = v),
                      ),
                      const SizedBox(height: 24),

                      // 연회비 자동이체 계좌
                      const Text(
                        '연회비 자동이체 계좌',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '연회비가 자동으로 출금될 계좌를 선택해 주세요.',
                        style: TextStyle(fontSize: 12, color: AppColors.gray600),
                      ),
                      const SizedBox(height: 12),

                      ...accounts.where((a) => a.accountStatus == 'ACTIVE').map((a) =>
                          _AccountTile(
                            account:    a,
                            isSelected: _linkedAccountId == a.accountId,
                            onTap:      () => setState(() => _linkedAccountId = a.accountId),
                          ),
                      ),

                      if (appState.error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.',
                                  style: TextStyle(fontSize: 13, color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BnkButton(
                label:     '다음',
                isLoading: appState.isLoading,
                onPressed: _canNext
                    ? () async {
                  await appNotifier.saveApplicantInfo(
                    applicantSnapshot: CreditApplicantSnapshot(
                      name:                _nameCtrl.text.trim(),
                      nameEn:              _nameEnCtrl.text.trim().isEmpty
                          ? null
                          : _nameEnCtrl.text.trim(),
                      mobileNo:            _mobileCtrl.text.trim(),
                      address: [_addressCtrl.text.trim(), _addrDetailCtrl.text.trim()]
                          .where((s) => s.isNotEmpty).join(' '),
                      email:               _emailCtrl.text.trim(),
                      incomeType:          _incomeType,
                      healthInsuranceType: _healthInsuranceType,
                      hasRealEstate:       _hasRealEstate,
                      hasOwnVehicle:       _hasOwnVehicle,
                    ),
                    annualIncomeBand: _annualIncomeBand!,
                    creditScoreBand:  _creditScoreBand!,
                    linkedAccountId:  _linkedAccountId!,
                  );

                  if (context.mounted && appState.error == null) {
                    context.push(
                      '/application/credit/step4',
                      extra: widget.cardId,
                    );
                  }
                }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 공통 입력 필드 ─────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final void Function(String) onChanged;
  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextField(
          controller:   controller,
          keyboardType: keyboardType,
          onChanged:    onChanged,
          decoration: InputDecoration(
            hintText:  hint,
            hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.teal600),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 드롭다운 ──────────────────────────────────────────────────────

class _Dropdown extends StatelessWidget {
  final String              label;
  final String?             value;
  final Map<String, String> items;
  final void Function(String?) onChanged;
  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          hint: Text('선택해 주세요',
              style: const TextStyle(fontSize: 13, color: AppColors.gray400)),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.teal600),
            ),
          ),
          items: items.entries.map((e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value, style: const TextStyle(fontSize: 13)),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

// ── Y/N 토글 ──────────────────────────────────────────────────────

class _YNToggle extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;
  const _YNToggle({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        ),
        GestureDetector(
          onTap: () => onChanged(value == 'Y' ? 'N' : 'Y'),
          child: Container(
            width: 48, height: 26,
            decoration: BoxDecoration(
              color: value == 'Y' ? AppColors.teal600 : AppColors.gray200,
              borderRadius: BorderRadius.circular(13),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: value == 'Y'
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 20, height: 20,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── 계좌 선택 타일 ────────────────────────────────────────────────

class _AccountTile extends StatelessWidget {
  final AccountModel account;
  final bool         isSelected;
  final VoidCallback onTap;
  const _AccountTile({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal50 : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.teal600 : AppColors.gray200,
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    account.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? AppColors.teal800 : AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account.accountNumber,
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.teal600, size: 20),
          ],
        ),
      ),
    );
  }
}