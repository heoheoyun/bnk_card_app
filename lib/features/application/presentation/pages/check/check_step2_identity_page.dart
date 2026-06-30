import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../presentation/providers/check_application_provider.dart';
import '../../../presentation/widgets/application_step_indicator.dart';
import '../../../presentation/widgets/identity_form_widget.dart';

class CheckStep2IdentityPage extends ConsumerStatefulWidget {
  final int cardId;
  const CheckStep2IdentityPage({super.key, required this.cardId});

  @override
  ConsumerState<CheckStep2IdentityPage> createState() =>
      _CheckStep2IdentityPageState();
}

class _CheckStep2IdentityPageState
    extends ConsumerState<CheckStep2IdentityPage> {

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

  /// 주민번호(앞6+성별코드1)에서 생년월일(yyyy-MM-dd) 파생 — 한도 산정용
  String? _birthDateFromResidentNo(String? r) {
    if (r == null || r.length < 7) return null;
    final f = r.substring(0, 6);
    final g = r.substring(6, 7);
    final century = switch (g) {
      '1' || '2' || '7' || '8' => 1900,
      '3' || '4' || '9' || '0' => 2000,
      _ => null,
    };
    if (century == null) return null;
    final y = century + int.parse(f.substring(0, 2));
    return '$y-${f.substring(2, 4)}-${f.substring(4, 6)}';
  }

  @override
  Widget build(BuildContext context) {
    final appState    = ref.watch(checkApplicationProvider);
    final appNotifier = ref.read(checkApplicationProvider.notifier);

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: const BnkAppBar(title: '카드 신청', showBack: false),
        body: Column(
          children: [
            ApplicationStepIndicator(currentStep: 2, totalSteps: 4),

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

                    // 안내 문구 추가
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.teal50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.teal200),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppColors.teal600, size: 18),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '만 19세 미만 미성년자는 온라인 신청이 불가합니다.\n가까운 BNK 부산은행 영업점을 방문해 주세요.',
                              style: TextStyle(fontSize: 12, color: AppColors.teal800, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    IdentityFormWidget(
                      onChanged: ({
                        required idType,
                        required idName,
                        required idResidentNo,
                        required idAddress,
                        required idIssueDate,
                      }) {
                        setState(() {
                          _idType       = idType;
                          _idName       = idName;
                          _idResidentNo = idResidentNo;
                          _idAddress    = idAddress;
                          _idIssueDate  = idIssueDate;
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

                    final latest = ref.read(checkApplicationProvider);
                    if (context.mounted && latest.error == null) {
                      // step3 신청정보 폼에 자동 반영될 수 있도록 snapshot 채움
                      appNotifier.prefillApplicantFromIdentity(
                        name:      _idName!,
                        birthDate: _birthDateFromResidentNo(_idResidentNo),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('본인확인이 완료되었습니다.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      context.push('/application/check/step3',extra: widget.cardId);
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