import 'package:flutter/material.dart';
import '../../data/models/terms_model.dart';
import '../../../../core/constants/app_colors.dart';
import 'terms_files_sheet.dart';

/// 약관 목록의 개별 항목 타일.
///
/// - 필수/선택 배지 표시
/// - 체크 토글
/// - '보기' 버튼 → TermsDetailBottomSheet 호출 (선택)
class TermsItemTile extends StatelessWidget {
  final TermsModel  terms;
  final bool        agreed;
  final VoidCallback onToggle;

  const TermsItemTile({
    super.key,
    required this.terms,
    required this.agreed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 체크박스
          GestureDetector(
            onTap: onToggle,
            child: Icon(
              agreed ? Icons.check_circle : Icons.check_circle_outline,
              color: agreed ? AppColors.primary : Colors.grey.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 필수/선택 배지 + 제목
          Expanded(
            child: Row(
              children: [
                _RequiredBadge(required: terms.required),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    terms.title,
                    style: const TextStyle(fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // 보기 버튼
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              builder: (context) => TermsFilesSheet(
                termsId: terms.termsId,
                title:   terms.title,
              ),
            ),
            child: const Text(
              '보기',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  final bool required;
  const _RequiredBadge({required this.required});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: required
            ? AppColors.primary.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        required ? '필수' : '선택',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: required ? AppColors.primary : Colors.grey.shade500,
        ),
      ),
    );
  }
}