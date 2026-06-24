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

  @override
  Widget build(BuildContext context) {
    final appState    = ref.watch(checkApplicationProvider);
    final appNotifier = ref.read(checkApplicationProvider.notifier);

    return Scaffold(
      appBar: const BnkAppBar(title: '카드 신청'),
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
                    Text(
                      appState.error!,
                      style: const TextStyle(fontSize: 13, color: Colors.red),
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

                  if (context.mounted && appState.error == null) {
                    context.push(
                      '/application/check/step3',
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