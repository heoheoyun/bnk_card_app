import 'package:flutter/material.dart';
import '../../data/models/terms_model.dart';
import '../../../../core/constants/app_colors.dart';
import 'terms_files_sheet.dart';

class TermsItemTile extends StatefulWidget {
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
  State<TermsItemTile> createState() => _TermsItemTileState();
}

class _TermsItemTileState extends State<TermsItemTile> {
  bool _viewed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 체크박스
          GestureDetector(
            onTap: () {
              if (!_viewed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('약관을 먼저 확인해 주세요.'),
                    duration: Duration(seconds: 1),
                  ),
                );
                return;
              }
              widget.onToggle();
            },
            child: Icon(
              widget.agreed ? Icons.check_circle : Icons.check_circle_outline,
              color: !_viewed
                  ? Colors.grey.shade200
                  : (widget.agreed ? AppColors.primary : Colors.grey.shade400),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // 필수/선택 배지 + 제목
          Expanded(
            child: Row(
              children: [
                _RequiredBadge(required: widget.terms.required),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    widget.terms.title,
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
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) => TermsFilesSheet(
                  termsId: widget.terms.termsId,
                  title:   widget.terms.title,
                ),
              );
              if (mounted) setState(() => _viewed = true);
            },
            child: Text(
              '보기',
              style: TextStyle(
                fontSize: 12,
                color: _viewed ? AppColors.primary : AppColors.textMuted,
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