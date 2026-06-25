import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../presentation/providers/credit_application_provider.dart';
import '../../../presentation/widgets/application_step_indicator.dart';
import '../../../presentation/widgets/identity_form_widget.dart';

class CreditStep2IdentityPage extends ConsumerStatefulWidget {
  final int cardId;
  const CreditStep2IdentityPage({super.key, required this.cardId});

  @override
  ConsumerState<CreditStep2IdentityPage> createState() =>
      _CreditStep2IdentityPageState();
}

class _CreditStep2IdentityPageState
    extends ConsumerState<CreditStep2IdentityPage> {

  String? _idType;
  String? _idName;
  String? _idResidentNo;
  String? _idAddress;
  String? _idIssueDate;

  bool get _canNext =>
      _idType != null &&
          _idName != null && _idName!.isNotEmpty &&
          _idResidentNo != null && _idResidentNo!.length == 7 &&
          _idAddress != null && _idAddress!.isNotEmpty &&
          _idIssueDate != null && _idIssueDate!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final appState    = ref.watch(creditApplicationProvider);
    final appNotifier = ref.read(creditApplicationProvider.notifier);

    return PopScope(
      canPop: false,
      // #17 안드로이드 시스템 백이 완전히 막혀 '먹통'이던 문제 해결.
      // 확인 후 이전 단계(step1)로 이동. step1 의 재전진 가드 덕에 바운스 없음.
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final leave = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            title: const Text('이전 단계로'),
            content: const Text('본인확인 단계를 벗어날까요?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('취소')),
              TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('나가기')),
            ],
          ),
        );
        if (leave == true && context.mounted) {
          context.pushReplacement('/application/credit/step1',
              extra: widget.cardId);
        }
      },
      child: Scaffold(
        appBar: const BnkAppBar(title: '카드 신청'),
        body: Column(
          children: [
            ApplicationStepIndicator(currentStep: 2, totalSteps: 5),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '본인확인',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '신분증 정보를 입력해 주세요.',
                      style: TextStyle(fontSize: 13, color: AppColors.gray600),
                    ),
                    const SizedBox(height: 24),

                    IdentityFormWidget(
                      onChanged: ({
                        required idType,
                        required idName,
                        required idResidentNo,
                        required idAddress,
                        required idIssueDate,
                      }) {
                        setState(() {
                          _idType      = idType;
                          _idName      = idName;
                          _idResidentNo = idResidentNo;
                          _idAddress   = idAddress;
                          _idIssueDate = idIssueDate;
                        });
                      },
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
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                '본인확인에 실패했습니다. 입력 정보를 확인해 주세요.',
                                style: TextStyle(fontSize: 13, color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
                    await appNotifier.verifyIdentity(
                      idType:       _idType!,
                      idName:       _idName!,
                      idResidentNo: _idResidentNo!,
                      idAddress:    _idAddress!,
                      idIssueDate:  _idIssueDate!,
                    );

                    final latest = ref.read(creditApplicationProvider);
                    if (context.mounted && latest.error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('본인확인이 완료되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.push('/application/credit/step3', extra: widget.cardId);
                    }
                  }
                      : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}