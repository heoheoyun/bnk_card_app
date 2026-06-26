
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

  bool _isAdult() {
    if (_idResidentNo == null || _idResidentNo!.length < 7) return false;

    final front      = _idResidentNo!.substring(0, 6); // YYMMDD
    final genderCode = _idResidentNo!.substring(6, 7);

    // 성별코드로 출생 세기 판단
    // 1,2 → 1900년대 / 3,4 → 2000년대 / 7,8,9,0 → 외국인
    int century;
    switch (genderCode) {
      case '1': case '2': century = 1900; break;
      case '3': case '4': century = 2000; break;
      case '7': case '8': century = 1900; break; // 외국인 1900년대
      case '9': case '0': century = 2000; break; // 외국인 2000년대
      default: return false;
    }

    final year  = century + int.parse(front.substring(0, 2));
    final month = int.parse(front.substring(2, 4));
    final day   = int.parse(front.substring(4, 6));

    final birthDate = DateTime(year, month, day);
    final today     = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age >= 19;
  }

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
      child: Scaffold(
        appBar: const BnkAppBar(title: '카드 신청', showBack: false),
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
                    // 나이 검증 (신용카드 = 만 19세 이상만)
                    if (!_isAdult()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('신용카드는 만 19세 이상만 신청 가능합니다.'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    final verified = await appNotifier.verifyIdentity(
                      idType:       _idType!,
                      idName:       _idName!,
                      idResidentNo: _idResidentNo!,
                      idAddress:    _idAddress!,
                      idIssueDate:  _idIssueDate!,
                    );

                    if (!verified || !context.mounted) return; // 실패면 여기서 차단

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('본인확인이 완료되었습니다.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    context.push('/application/credit/step3', extra: widget.cardId);
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