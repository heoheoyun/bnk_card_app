import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../domain/entities/check_application.dart';
import '../../../presentation/providers/check_application_provider.dart';
import '../../../presentation/widgets/application_step_indicator.dart';

class CheckStep3ApplicantPage extends ConsumerStatefulWidget {
  final int cardId;
  const CheckStep3ApplicantPage({super.key, required this.cardId});

  @override
  ConsumerState<CheckStep3ApplicantPage> createState() =>
      _CheckStep3ApplicantPageState();
}

class _CheckStep3ApplicantPageState
    extends ConsumerState<CheckStep3ApplicantPage> {

  final _nameCtrl    = TextEditingController();
  final _nameEnCtrl  = TextEditingController();
  final _mobileCtrl  = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _emailCtrl   = TextEditingController();

  String? _jobType;
  String? _transactionPurpose;
  String? _fundSource;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameEnCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool get _canNext =>
      _nameCtrl.text.isNotEmpty &&
          _mobileCtrl.text.isNotEmpty &&
          _addressCtrl.text.isNotEmpty &&
          _emailCtrl.text.isNotEmpty &&
          _jobType != null &&
          _transactionPurpose != null &&
          _fundSource != null;

  @override
  Widget build(BuildContext context) {
    final appState    = ref.watch(checkApplicationProvider);
    final appNotifier = ref.read(checkApplicationProvider.notifier);

    return Scaffold(
      appBar: const BnkAppBar(title: '카드 신청'),
      body: Column(
        children: [
          ApplicationStepIndicator(currentStep: 3, totalSteps: 4),

          Expanded(
            child: SingleChildScrollView(
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
                      hint: '이름을 입력해 주세요',
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),

                  // 영문 이름 (선택)
                  _Field(label: '영문 이름 (선택)', controller: _nameEnCtrl,
                      hint: 'HONG GILDONG',
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),

                  // 휴대폰 번호
                  _Field(label: '휴대폰 번호', controller: _mobileCtrl,
                      hint: '010-0000-0000',
                      keyboardType: TextInputType.phone,
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),

                  // 주소
                  _Field(label: '주소', controller: _addressCtrl,
                      hint: '주소를 입력해 주세요',
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 16),

                  // 이메일
                  _Field(label: '이메일', controller: _emailCtrl,
                      hint: 'example@email.com',
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {})),
                  const SizedBox(height: 24),

                  const Text(
                    '거래 정보',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),

                  // 직업 구분
                  _Dropdown(
                    label: '직업 구분',
                    value: _jobType,
                    items: const {
                      'EMPLOYED':      '직장인',
                      'SELF_EMPLOYED': '자영업자',
                      'STUDENT':       '학생',
                      'HOUSEWIFE':     '주부',
                      'OTHER':         '기타',
                    },
                    onChanged: (v) => setState(() => _jobType = v),
                  ),
                  const SizedBox(height: 16),

                  // 거래 목적
                  _Dropdown(
                    label: '거래 목적',
                    value: _transactionPurpose,
                    items: const {
                      'SALARY':       '급여이체',
                      'LIVING':       '생활비',
                      'SAVINGS':      '저축',
                      'BUSINESS':     '사업',
                      'OTHER':        '기타',
                    },
                    onChanged: (v) => setState(() => _transactionPurpose = v),
                  ),
                  const SizedBox(height: 16),

                  // 자금 출처
                  _Dropdown(
                    label: '자금 출처',
                    value: _fundSource,
                    items: const {
                      'LABOR_INCOME':    '근로소득',
                      'BUSINESS_INCOME': '사업소득',
                      'PENSION':         '연금',
                      'INHERITANCE':     '상속/증여',
                      'OTHER':           '기타',
                    },
                    onChanged: (v) => setState(() => _fundSource = v),
                  ),

                  if (appState.error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      appState.error!,
                      style: const TextStyle(fontSize: 13, color: Colors.red),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
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
                    applicantSnapshot: CheckApplicantSnapshot(
                      name:               _nameCtrl.text.trim(),
                      nameEn:             _nameEnCtrl.text.trim().isEmpty
                          ? null
                          : _nameEnCtrl.text.trim(),
                      mobileNo:           _mobileCtrl.text.trim(),
                      address:            _addressCtrl.text.trim(),
                      email:              _emailCtrl.text.trim(),
                      jobType:            _jobType,
                      transactionPurpose: _transactionPurpose,
                      fundSource:         _fundSource,
                    ),
                  );

                  if (context.mounted && appState.error == null) {
                    context.push(
                      '/application/check/step4',
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

// ── 공통 입력 필드 ────────────────────────────────────────────────

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
          hint: const Text('선택해 주세요',
              style: TextStyle(fontSize: 13, color: AppColors.gray400)),
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