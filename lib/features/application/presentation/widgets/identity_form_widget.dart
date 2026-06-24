import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';

class IdentityFormWidget extends StatefulWidget {
  final void Function({
  required String idType,
  required String idName,
  required String idResidentNo,
  required String idAddress,
  required String idIssueDate,
  }) onChanged;

  const IdentityFormWidget({super.key, required this.onChanged});

  @override
  State<IdentityFormWidget> createState() => _IdentityFormWidgetState();
}

class _IdentityFormWidgetState extends State<IdentityFormWidget> {
  String _idType      = 'RESIDENT'; // RESIDENT / DRIVER
  final _nameCtrl     = TextEditingController();
  final _residentFrontCtrl = TextEditingController();
  final _residentBackCtrl  = TextEditingController();
  final _addressCtrl  = TextEditingController();
  final _issueDateCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _residentFrontCtrl.dispose();
    _residentBackCtrl.dispose();
    _addressCtrl.dispose();
    _issueDateCtrl.dispose();
    super.dispose();
  }

  void _notify() {
    widget.onChanged(
      idType:       _idType,
      idName:       _nameCtrl.text.trim(),
      idResidentNo: _residentFrontCtrl.text.trim() + _residentBackCtrl.text.trim(),
      idAddress:    _addressCtrl.text.trim(),
      idIssueDate:  _issueDateCtrl.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // 신분증 종류 선택
        const Text('신분증 종류', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            _TypeChip(
              label:    '주민등록증',
              selected: _idType == 'RESIDENT',
              onTap:    () => setState(() { _idType = 'RESIDENT'; _notify(); }),
            ),
            const SizedBox(width: 8),
            _TypeChip(
              label:    '운전면허증',
              selected: _idType == 'DRIVER',
              onTap:    () => setState(() { _idType = 'DRIVER'; _notify(); }),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 이름
        _Field(
          label:       '이름',
          hint:        '이름을 입력해 주세요',
          controller:  _nameCtrl,
          onChanged:   (_) => _notify(),
        ),
        const SizedBox(height: 16),

        // 주민등록번호 앞 7자리
        // 기존 _Field 대신 아래로 교체
        const Text('주민등록번호', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Row(
          children: [
            // 앞 6자리
            Expanded(
              child: TextField(
                controller:   _residentFrontCtrl,
                keyboardType: TextInputType.number,
                maxLength:    6,
                onChanged:    (v) {
                  if (v.length == 6) FocusScope.of(context).nextFocus();
                  _notify();
                },
                decoration: InputDecoration(
                  hintText:    '앞 6자리',
                  counterText: '',
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
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('-', style: TextStyle(fontSize: 16, color: AppColors.gray600)),
            ),
            // 뒷 첫째 자리
            SizedBox(
              width: 40,
              child: TextField(
                controller:   _residentBackCtrl,
                keyboardType: TextInputType.number,
                maxLength:    1,
                onChanged:    (_) => _notify(),
                decoration: InputDecoration(
                  counterText: '',
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
            ),
            const SizedBox(width: 4),
            // 나머지 6자리 마스킹
            const Text(
              '●●●●●●',
              style: TextStyle(fontSize: 16, color: AppColors.gray400, letterSpacing: 2),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 주소
        _Field(
          label:       '주소',
          hint:        '주소를 입력해 주세요',
          controller:  _addressCtrl,
          onChanged:   (_) => _notify(),
        ),
        const SizedBox(height: 16),

        // 발급일
        _Field(
          label:       '발급일',
          hint:        'YYYY-MM-DD',
          controller:  _issueDateCtrl,
          keyboardType: TextInputType.datetime,
          onChanged:   (_) => _notify(),
        ),
      ],
    );
  }
}

// ── 신분증 종류 칩 ────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;
  const _TypeChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal600 : Colors.white,
          border: Border.all(
            color: selected ? AppColors.teal600 : AppColors.gray200,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }
}

// ── 공통 입력 필드 ────────────────────────────────────────────────

class _Field extends StatelessWidget {
  final String             label;
  final String             hint;
  final TextEditingController controller;
  final TextInputType?     keyboardType;
  final int?               maxLength;
  final void Function(String) onChanged;

  const _Field({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.keyboardType,
    this.maxLength,
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
          maxLength:    maxLength,
          onChanged:    onChanged,
          decoration: InputDecoration(
            hintText:      hint,
            hintStyle:     const TextStyle(fontSize: 13, color: AppColors.gray400),
            counterText:   '',
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:   const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:   const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:   const BorderSide(color: AppColors.teal600),
            ),
          ),
        ),
      ],
    );
  }
}