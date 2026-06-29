import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../domain/entities/credit_application.dart';
import '../../../presentation/providers/check_application_provider.dart';
import '../../../presentation/providers/account_provider.dart';
import '../../../presentation/widgets/application_step_indicator.dart';

class CheckStep4PaymentPage extends ConsumerStatefulWidget {
  final int cardId;
  const CheckStep4PaymentPage({super.key, required this.cardId});

  @override
  ConsumerState<CheckStep4PaymentPage> createState() =>
      _CheckStep4PaymentPageState();
}

class _CheckStep4PaymentPageState
    extends ConsumerState<CheckStep4PaymentPage> {

  String  _cardBrand         = 'LOCAL';
  String  _combinedTransitYn = 'N';
  String  _txAlertType       = 'PUSH';
  String  _statementMethod   = 'APP';
  int?    _linkedAccountId;

  final _passwordCtrl  = TextEditingController();
  final _password2Ctrl = TextEditingController();

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _password2Ctrl.dispose();
    super.dispose();
  }

  bool get _canNext =>
      _linkedAccountId != null &&
          _passwordCtrl.text.length == 4 &&
          _passwordCtrl.text == _password2Ctrl.text;

  @override
  Widget build(BuildContext context) {
    final appState     = ref.watch(checkApplicationProvider);
    final appNotifier  = ref.read(checkApplicationProvider.notifier);
    final accountAsync = ref.watch(myAccountsProvider);

    return Scaffold(
      appBar: const BnkAppBar(title: '카드 신청'),
      body: Column(
        children: [
          ApplicationStepIndicator(currentStep: 4, totalSteps: 4),

          Expanded(
            child: accountAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error:   (_, __) => const Center(child: Text('계좌 정보를 불러오지 못했습니다.')),
              data: (accounts) {
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
                        '신청정보',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 24),

                      // 출금 계좌 선택
                      const Text(
                        '출금 계좌',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '체크카드 결제 시 출금될 계좌를 선택해 주세요.',
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
                      const SizedBox(height: 20),

                      // 카드 브랜드
                      const Text('카드 브랜드',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['LOCAL', 'VISA', 'MASTER'].map((b) =>
                            _SelectChip(
                              label:    b,
                              selected: _cardBrand == b,
                              onTap:    () => setState(() => _cardBrand = b),
                            ),
                        ).toList(),
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
                      const Text('거래 알림',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                      const Text('청구서 수령 방법',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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

                      // 카드 비밀번호
                      const Text('카드 비밀번호',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
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
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BnkButton(
                label:     '신청 완료',
                isLoading: appState.isLoading,
                onPressed: _canNext
                    ? () async {
                  await appNotifier.submitApplication(
                    paymentSnapshot: PaymentSnapshot(
                      cardBrand:         _cardBrand,
                      combinedTransitYn: _combinedTransitYn,
                      txAlertType:       _txAlertType,
                      statementMethod:   _statementMethod,
                    ),
                    linkedAccountId: _linkedAccountId!,
                    cardPassword:    _passwordCtrl.text,
                  );

                  if (context.mounted && appState.error == null) {
                    context.push(
                      '/application/check/result',
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

// ── 헬퍼 위젯 ────────────────────────────────────────────────────

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