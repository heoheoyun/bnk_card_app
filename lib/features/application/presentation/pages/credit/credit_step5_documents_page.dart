import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';
import '../../../presentation/providers/credit_application_provider.dart';
import '../../../presentation/widgets/application_step_indicator.dart';

class CreditStep5DocumentsPage extends ConsumerStatefulWidget {
  final int cardId;
  const CreditStep5DocumentsPage({super.key, required this.cardId});

  @override
  ConsumerState<CreditStep5DocumentsPage> createState() =>
      _CreditStep5DocumentsPageState();
}

class _CreditStep5DocumentsPageState
    extends ConsumerState<CreditStep5DocumentsPage> {

  PlatformFile? _incomeDoc;
  PlatformFile? _assetDoc;
  PlatformFile? _jobDoc;
  bool _isUploading = false;

  bool get _canNext => _incomeDoc != null && _jobDoc != null;

  Future<void> _pickFile(String type) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      switch (type) {
        case 'income': _incomeDoc = result.files.first;
        case 'asset':  _assetDoc  = result.files.first;
        case 'job':    _jobDoc    = result.files.first;
      }
    });
  }

  Future<void> _submit(int creditAppId) async {
    setState(() => _isUploading = true);
    try {
      // 1. 서류 업로드
      final formData = FormData.fromMap({
        'creditAppId': creditAppId,
        'incomeDoc': await MultipartFile.fromFile(
            _incomeDoc!.path!, filename: _incomeDoc!.name),
        if (_assetDoc != null)
          'assetDoc': await MultipartFile.fromFile(
              _assetDoc!.path!, filename: _assetDoc!.name),
        'jobDoc': await MultipartFile.fromFile(
            _jobDoc!.path!, filename: _jobDoc!.name),
      });

      final res  = await DioClient.instance.post(
          '/api/applications/credit/docs', data: formData);
      final data = res.data['data'] as Map<String, dynamic>;

      // 2. submit 호출
      await ref.read(creditApplicationProvider.notifier).submitApplication(
        incomeDocKey: data['incomeDocKey'] as String,
        assetDocKey:  data['assetDocKey']  as String?,
        jobDocKey:    data['jobDocKey']    as String,
      );

      if (mounted && ref.read(creditApplicationProvider).error == null) {
        context.push('/application/credit/result', extra: widget.cardId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서류 업로드 실패: $e')),
        );
      }
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(creditApplicationProvider);

    return Scaffold(
      appBar: const BnkAppBar(title: '카드 신청'),
      body: Column(
        children: [
          ApplicationStepIndicator(currentStep: 5, totalSteps: 5),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '서류 제출',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '신규 고객은 소득 및 직업 확인 서류를 제출해야 합니다.',
                    style: TextStyle(fontSize: 13, color: AppColors.gray600),
                  ),
                  const SizedBox(height: 24),

                  // 소득확인서류 (필수)
                  _DocUploadTile(
                    label:      '소득확인서류',
                    isRequired: true,
                    file:       _incomeDoc,
                    onTap:      () => _pickFile('income'),
                  ),
                  const SizedBox(height: 12),

                  // 직업확인서류 (필수)
                  _DocUploadTile(
                    label:      '직업확인서류',
                    isRequired: true,
                    file:       _jobDoc,
                    onTap:      () => _pickFile('job'),
                  ),
                  const SizedBox(height: 12),

                  // 재산확인서류 (선택)
                  _DocUploadTile(
                    label:      '재산확인서류',
                    isRequired: false,
                    file:       _assetDoc,
                    onTap:      () => _pickFile('asset'),
                  ),

                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.teal50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '• PDF, JPG, PNG 형식만 가능합니다.\n• 파일 크기는 20MB 이하여야 합니다.',
                      style: TextStyle(fontSize: 12, color: AppColors.teal800),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: BnkButton(
                label:     '신청 완료',
                isLoading: _isUploading || appState.isLoading,
                onPressed: _canNext
                    ? () => _submit(appState.creditAppId!)
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 서류 업로드 타일 ──────────────────────────────────────────────

class _DocUploadTile extends StatelessWidget {
  final String        label;
  final bool          isRequired;
  final PlatformFile? file;
  final VoidCallback  onTap;
  const _DocUploadTile({
    required this.label,
    required this.isRequired,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: file != null ? AppColors.teal50 : Colors.white,
          border: Border.all(
            color: file != null ? AppColors.teal600 : AppColors.gray200,
            width: file != null ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              file != null ? Icons.check_circle : Icons.upload_file_outlined,
              color: file != null ? AppColors.teal600 : AppColors.gray400,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isRequired ? '(필수)' : '(선택)',
                        style: TextStyle(
                          fontSize: 11,
                          color: isRequired ? Colors.red : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  if (file != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      file!.name,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.teal600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ] else ...[
                    const SizedBox(height: 2),
                    const Text(
                      '파일을 선택해 주세요',
                      style: TextStyle(fontSize: 12, color: AppColors.gray400),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.gray400,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}