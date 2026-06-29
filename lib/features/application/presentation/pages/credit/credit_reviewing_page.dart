import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/network/dio_client.dart';
import '../../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../../shared/widgets/bnk_button.dart';

class CreditReviewingPage extends ConsumerStatefulWidget {
  final int creditAppId;
  const CreditReviewingPage({super.key, required this.creditAppId});

  @override
  ConsumerState<CreditReviewingPage> createState() => _CreditReviewingPageState();
}

class _CreditReviewingPageState extends ConsumerState<CreditReviewingPage> {
  PlatformFile? _incomeDoc;
  PlatformFile? _assetDoc;
  PlatformFile? _jobDoc;
  bool _isUploading = false;
  bool _submitted   = false;

  bool get _canSubmit => _incomeDoc != null && _jobDoc != null;

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

  Future<void> _resubmit() async {
    setState(() => _isUploading = true);
    try {
      final formData = FormData.fromMap({
        'incomeDoc': await MultipartFile.fromFile(
            _incomeDoc!.path!, filename: _incomeDoc!.name),
        if (_assetDoc != null)
          'assetDoc': await MultipartFile.fromFile(
              _assetDoc!.path!, filename: _assetDoc!.name),
        'jobDoc': await MultipartFile.fromFile(
            _jobDoc!.path!, filename: _jobDoc!.name),
      });

      await DioClient.instance.put(
        '/api/applications/credit/${widget.creditAppId}/reviewing-docs',
        data: formData,
      );

      if (mounted) {
        setState(() => _submitted = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서류 재제출 실패: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/mypage');
      },
      child: Scaffold(
        appBar: const BnkAppBar(title: '추가 서류 제출'),
        body: _submitted ? _buildDoneBody() : _buildFormBody(),
      ),
    );
  }

  // ── 제출 완료 화면 ──────────────────────────────────────────────
  Widget _buildDoneBody() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72, height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.teal50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.teal600,
                    size: 44,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '서류가 재제출되었습니다',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '담당자가 서류를 검토한 후 심사 결과를\n알림으로 안내드립니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                    height: 1.6,
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
              label: '마이페이지로',
              onPressed: () => context.go('/mypage'),
            ),
          ),
        ),
      ],
    );
  }

  // ── 서류 재제출 폼 ──────────────────────────────────────────────
  Widget _buildFormBody() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 안내 배너 (#2 - 설명 문구)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF8E1),
                    border: Border.all(color: const Color(0xFFFFE082)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.info_outline,
                              color: Color(0xFFF59E0B), size: 18),
                          SizedBox(width: 6),
                          Text(
                            '추가 서류 제출 안내',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF92400E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '카드 발급 심사를 위해 서류 확인이 필요합니다.\n'
                        '이전에 제출하신 서류의 진위 확인을 위해 아래 서류를 다시 제출해 주세요.\n\n'
                        '• 소득확인서류: 근로소득원천징수영수증, 급여명세서 등\n'
                        '• 직업확인서류: 재직증명서, 사업자등록증 등\n'
                        '• 재산확인서류: 부동산등기부등본 등 (선택)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  '서류 재제출',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '소득확인서류와 직업확인서류는 필수 제출 항목입니다.',
                  style: TextStyle(fontSize: 13, color: AppColors.gray600),
                ),
                const SizedBox(height: 20),

                _DocUploadTile(
                  label:      '소득확인서류',
                  isRequired: true,
                  file:       _incomeDoc,
                  onTap:      () => _pickFile('income'),
                ),
                const SizedBox(height: 12),
                _DocUploadTile(
                  label:      '직업확인서류',
                  isRequired: true,
                  file:       _jobDoc,
                  onTap:      () => _pickFile('job'),
                ),
                const SizedBox(height: 12),
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
              label:     '서류 재제출',
              isLoading: _isUploading,
              onPressed: _canSubmit ? _resubmit : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ── 서류 업로드 타일 (Step5와 동일) ──────────────────────────────
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
                      Text(label,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500)),
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
                  const SizedBox(height: 2),
                  if (file != null)
                    Text(file!.name,
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.teal600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)
                  else
                    const Text('파일을 선택해 주세요',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.gray400)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.gray400, size: 18),
          ],
        ),
      ),
    );
  }
}
