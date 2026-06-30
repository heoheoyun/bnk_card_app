import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../domain/entities/credit_application.dart';
import '../../../presentation/providers/credit_application_provider.dart';
import '../../../presentation/widgets/application_step_indicator.dart';
import '../../../../mypage/data/models/address_model.dart';
import '../../../../mypage/presentation/providers/mypage_provider.dart';

class CreditStep4PaymentPage extends ConsumerStatefulWidget {
  final int cardId;
  const CreditStep4PaymentPage({super.key, required this.cardId});

  @override
  ConsumerState<CreditStep4PaymentPage> createState() =>
      _CreditStep4PaymentPageState();
}

class _CreditStep4PaymentPageState
    extends ConsumerState<CreditStep4PaymentPage> {

  String  _cardBrand         = 'LOCAL';
  int     _paymentDay        = 15;
  String  _combinedTransitYn = 'N';
  String  _txAlertType       = 'PUSH';
  String  _statementMethod   = 'APP';
  int     _requestedLimit    = 500000;

  final _passwordCtrl  = TextEditingController();
  final _password2Ctrl = TextEditingController();

  Address? _delivery; // 사용자가 선택한 배송지 (미선택 시 기본배송지 사용)

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  bool get _canNext =>
      _passwordCtrl.text.length == 4 &&
          _passwordCtrl.text == _password2Ctrl.text;

  @override
  Widget build(BuildContext context) {
    final appState    = ref.watch(creditApplicationProvider);

    // 배송지: 사용자가 고른 값 우선, 없으면 기본배송지 → 첫 주소
    final addrs = ref.watch(addressesProvider).valueOrNull;
    final Address? effectiveDelivery = _delivery ??
        (addrs == null || addrs.isEmpty
            ? null
            : addrs.firstWhere((a) => a.isDefault, orElse: () => addrs.first));

    return Scaffold(
      appBar: const BnkAppBar(title: '카드 신청'),
      body: Column(
        children: [
          ApplicationStepIndicator(currentStep: 4, totalSteps: 5),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '신청정보',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 24),

                  // 배송지
                  _SectionTitle('카드 배송지'),
                  const SizedBox(height: 8),
                  _DeliveryTile(
                    address: effectiveDelivery,
                    onTap: () async {
                      final picked = await context.push<Address>(
                        '/application/delivery-select',
                        extra: effectiveDelivery?.addressId,
                      );
                      if (picked != null) setState(() => _delivery = picked);
                    },
                  ),
                  const SizedBox(height: 24),

                  // 카드 브랜드
                  _SectionTitle('카드 브랜드'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['LOCAL', 'VISA', 'MASTER', 'AMEX'].map((b) =>
                        _SelectChip(
                          label:    b,
                          selected: _cardBrand == b,
                          onTap:    () => setState(() => _cardBrand = b),
                        ),
                    ).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 결제일
                  _SectionTitle('결제일'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _paymentDay,
                    decoration: _inputDecoration(),
                    items: [1, 5, 10, 15, 20, 25].map((d) =>
                        DropdownMenuItem(value: d, child: Text('매월 $d일')),
                    ).toList(),
                    onChanged: (v) => setState(() => _paymentDay = v ?? 15),
                  ),
                  const SizedBox(height: 20),

                  // 후불교통 결합
                  _YNRow(
                    label:     '후불교통카드 결합',
                    value:     _combinedTransitYn,
                    onChanged: (v) => setState(() => _combinedTransitYn = v),
                  ),
                  const SizedBox(height: 20),

                  // 거래알림
                  _SectionTitle('거래 알림'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: {
                      'PUSH': 'PUSH',
                      'SMS':  'SMS',
                      'NONE': '없음',
                    }.entries.map((e) =>
                        _SelectChip(
                          label:    e.value,
                          selected: _txAlertType == e.key,
                          onTap:    () => setState(() => _txAlertType = e.key),
                        ),
                    ).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 청구서 방식
                  _SectionTitle('청구서 수령 방법'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: {
                      'APP':   '앱',
                      'EMAIL': '이메일',
                      'PAPER': '우편',
                    }.entries.map((e) =>
                        _SelectChip(
                          label:    e.value,
                          selected: _statementMethod == e.key,
                          onTap:    () => setState(() => _statementMethod = e.key),
                        ),
                    ).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 신청 한도
                  _SectionTitle('신청 한도'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    initialValue: _requestedLimit,
                    decoration: _inputDecoration(),
                    items: [
                      300000, 500000, 1000000, 3000000, 5000000
                    ].map((v) => DropdownMenuItem(
                      value: v,
                      child: Text('${(v / 10000).toInt()}만원'),
                    )).toList(),
                    onChanged: (v) => setState(() => _requestedLimit = v ?? 500000),
                  ),
                  const SizedBox(height: 20),

                  // 카드 비밀번호
                  _SectionTitle('카드 비밀번호'),
                  const SizedBox(height: 8),
                  TextField(
                    controller:   _passwordCtrl,
                    obscureText:  true,
                    maxLength:    4,
                    keyboardType: TextInputType.number,
                    onChanged:    (_) => setState(() {}),
                    decoration: _inputDecoration(hint: '숫자 4자리'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller:   _password2Ctrl,
                    obscureText:  true,
                    maxLength:    4,
                    keyboardType: TextInputType.number,
                    onChanged:    (_) => setState(() {}),
                    decoration: _inputDecoration(hint: '비밀번호 확인'),
                  ),
                  if (_password2Ctrl.text.isNotEmpty &&
                      _passwordCtrl.text != _password2Ctrl.text) ...[
                    const SizedBox(height: 6),
                    const Text(
                      '비밀번호가 일치하지 않습니다.',
                      style: TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ],

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
                              "심사 요청 중 오류가 발생했습니다. 고객센터에 문의해주세요. 1588-6200",
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
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BnkButton(
                label:     '다음',
                isLoading: appState.isLoading,

                onPressed: (_canNext && effectiveDelivery != null)
                    ? () async {
                  ref.read(creditApplicationProvider.notifier).savePaymentInfo(
                    paymentSnapshot: PaymentSnapshot(
                      cardBrand:         _cardBrand,
                      paymentDay:        _paymentDay,
                      combinedTransitYn: _combinedTransitYn,
                      txAlertType:       _txAlertType,
                      statementMethod:   _statementMethod,
                      deliveryAddress:   effectiveDelivery.fullAddress,
                      deliveryZipcode:   effectiveDelivery.zipcode,
                    ),
                    requestedLimit: _requestedLimit,
                    cardPassword:   _passwordCtrl.text,
                  );

                  // 기존고객이면 바로 submit, 신규고객이면 step5로
                  if (appState.isExistingCustomer) {
                    await ref.read(creditApplicationProvider.notifier).submitApplication();
                    if (context.mounted && ref.read(creditApplicationProvider).error == null) {
                      context.push('/application/credit/result', extra: widget.cardId);
                    }
                  } else {
                    context.push('/application/credit/step5', extra: widget.cardId);
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

// ── 헬퍼 위젯 ────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
  );
}

/// 배송지 선택 타일 — 선택된 주소를 보여주고 탭하면 배송지 선택 화면으로
class _DeliveryTile extends StatelessWidget {
  final Address? address;
  final VoidCallback onTap;
  const _DeliveryTile({required this.address, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasAddr = address != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasAddr ? AppColors.teal600 : AppColors.gray200,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.local_shipping_outlined,
                size: 20,
                color: hasAddr ? AppColors.teal600 : AppColors.gray400),
            const SizedBox(width: 12),
            Expanded(
              child: hasAddr
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          address!.alias?.isNotEmpty == true
                              ? address!.alias!
                              : '내 주소',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          address!.fullAddress,
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.gray600),
                        ),
                      ],
                    )
                  : const Text('배송지를 선택해 주세요',
                      style:
                          TextStyle(fontSize: 13, color: AppColors.gray400)),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }
}

InputDecoration _inputDecoration({String? hint}) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
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
);

class _SelectChip extends StatelessWidget {
  final String label;
  final bool   selected;
  final VoidCallback onTap;
  const _SelectChip({required this.label, required this.selected, required this.onTap});

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

class _YNRow extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String) onChanged;
  const _YNRow({required this.label, required this.value, required this.onChanged});

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
              alignment: value == 'Y' ? Alignment.centerRight : Alignment.centerLeft,
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