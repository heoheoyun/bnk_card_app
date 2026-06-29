import 'package:flutter/material.dart';
import '../../data/models/terms_model.dart';
import '../../../../core/constants/app_colors.dart';
import 'terms_files_sheet.dart';

class TermsItemTile extends StatelessWidget {  // StatefulWidget → StatelessWidget
  final TermsModel   terms;
  final bool         agreed;
  final bool         viewed;        // 추가
  final VoidCallback onToggle;
  final VoidCallback onViewed;      // 추가

  const TermsItemTile({
    super.key,
    required this.terms,
    required this.agreed,
    required this.viewed,           // 추가
    required this.onToggle,
    required this.onViewed,         // 추가
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (!viewed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('약관을 먼저 확인해 주세요.'), duration: Duration(seconds: 1)),
                );
                return;
              }
              onToggle();
            },
            child: Icon(
              agreed ? Icons.check_circle : Icons.check_circle_outline,
              color: !viewed
                  ? Colors.grey.shade200
                  : (agreed ? AppColors.primary : Colors.grey.shade400),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                _RequiredBadge(required: terms.required),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(terms.title, style: const TextStyle(fontSize: 14),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              final read = await TermsFilesSheet.show(context, terms.termsId, terms.title);
              if (read == true) {
                onViewed();         // 부모에 알리기만 함
                onToggle();         // 보기 완료 시 자동 체크
              }
            },
            child: Text('보기',
              style: TextStyle(
                fontSize: 12,
                color: viewed ? AppColors.primary : AppColors.textMuted,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
//
// class _TermsItemTileState extends State<TermsItemTile> {
//   bool _viewed = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           // 체크박스
//           GestureDetector(
//             onTap: () {
//               if (!_viewed) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                     content: Text('약관을 먼저 확인해 주세요.'),
//                     duration: Duration(seconds: 1),
//                   ),
//                 );
//                 return;
//               }
//               widget.onToggle();
//             },
//             child: Icon(
//               widget.agreed ? Icons.check_circle : Icons.check_circle_outline,
//               color: !_viewed
//                   ? Colors.grey.shade200
//                   : (widget.agreed ? AppColors.primary : Colors.grey.shade400),
//               size: 24,
//             ),
//           ),
//           const SizedBox(width: 12),
//
//           // 필수/선택 배지 + 제목
//           Expanded(
//             child: Row(
//               children: [
//                 _RequiredBadge(required: widget.terms.required),
//                 const SizedBox(width: 6),
//                 Expanded(
//                   child: Text(
//                     widget.terms.title,
//                     style: const TextStyle(fontSize: 14),
//                     maxLines: 2,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // 보기 버튼
//           TextButton(
//             style: TextButton.styleFrom(
//               padding: const EdgeInsets.symmetric(horizontal: 8),
//               minimumSize: Size.zero,
//               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//             ),
//             onPressed: () async {
//               final read = await TermsFilesSheet.show(
//                 context,
//                 widget.terms.termsId,
//                 widget.terms.title,
//               );
//               if (mounted && read == true) {
//                 setState(() => _viewed = true);
//                 if (!widget.agreed) {
//                   WidgetsBinding.instance.addPostFrameCallback((_) {
//                     if (mounted) widget.onToggle();
//                   });
//                 }
//               }
//             },
//             child: Text(
//               '보기',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: _viewed ? AppColors.primary : AppColors.textMuted,
//                 decoration: TextDecoration.underline,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

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