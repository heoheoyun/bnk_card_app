import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bnk_card_app/core/constants/app_colors.dart';
import 'package:bnk_card_app/shared/widgets/kakao_address_search_page.dart';

/// 카카오(다음) 우편번호 검색을 포함한 주소 입력 필드.
///
/// 컨트롤러는 부모가 소유한다 → 부모에서 검증(_canNext)·제출(snapshot)에 그대로 사용.
/// 제출 시 최종 주소는 보통 아래처럼 합쳐 보낸다:
/// ```dart
/// address: [addressController.text.trim(), detailController.text.trim()]
///     .where((s) => s.isNotEmpty).join(' '),
/// ```
class AddressSearchField extends StatelessWidget {
  final TextEditingController postcodeController; // 우편번호
  final TextEditingController addressController;   // 도로명(기본) 주소
  final TextEditingController detailController;    // 상세주소
  final String label;
  final bool isRequired;

  /// 주소가 채워진 뒤 호출 (부모의 setState 등). 상세주소 입력 시에도 호출됨.
  final VoidCallback? onChanged;

  const AddressSearchField({
    super.key,
    required this.postcodeController,
    required this.addressController,
    required this.detailController,
    this.label = '주소',
    this.isRequired = true,
    this.onChanged,
  });

  Future<void> _search(BuildContext context) async {
    FocusScope.of(context).unfocus();

    // 웹에서는 WebView 미지원 → 직접 입력 다이얼로그
    if (kIsWeb) {
      await _searchWeb(context);
      return;
    }

    final result = await Navigator.of(context).push<KakaoAddress>(
      MaterialPageRoute(builder: (_) => const KakaoAddressSearchPage()),
    );
    if (result != null) {
      postcodeController.text = result.zonecode;
      addressController.text = result.address;
      onChanged?.call();
    }
  }

  Future<void> _searchWeb(BuildContext context) async {
    final postcodeCtrl = TextEditingController();
    final addressCtrl  = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('주소 입력', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: postcodeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '우편번호',
                hintText: '예) 48058',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressCtrl,
              decoration: const InputDecoration(
                labelText: '도로명 주소',
                hintText: '예) 부산광역시 해운대구 센텀2로 24',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('확인', style: TextStyle(color: AppColors.teal600)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      postcodeController.text = postcodeCtrl.text.trim();
      addressController.text  = addressCtrl.text.trim();
      onChanged?.call();
    }

    postcodeCtrl.dispose();
    addressCtrl.dispose();
  }

  InputDecoration _dec(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 13, color: AppColors.gray400),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            if (isRequired)
              const Text(' *',
                  style: TextStyle(fontSize: 13, color: AppColors.teal600)),
          ],
        ),
        const SizedBox(height: 6),

        // 우편번호 + 검색 버튼
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: postcodeController,
                readOnly: true,
                onTap: () => _search(context),
                decoration: _dec('우편번호'),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              height: 46,
              width: 110,
              child: OutlinedButton(
                onPressed: () => _search(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.teal600,
                  side: const BorderSide(color: AppColors.teal600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('주소 검색'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 도로명(기본) 주소 — 검색으로만 채움
        TextField(
          controller: addressController,
          readOnly: true,
          onTap: () => _search(context),
          decoration: _dec('도로명 주소 (주소 검색 버튼)'),
          maxLines: 2,
          minLines: 1,
        ),
        const SizedBox(height: 8),

        // 상세주소 — 직접 입력
        TextField(
          controller: detailController,
          onChanged: (_) => onChanged?.call(),
          decoration: _dec('상세주소 (동·호수 등)'),
        ),
      ],
    );
  }
}
