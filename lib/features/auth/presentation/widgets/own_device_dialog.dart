import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// "이 기기가 본인 소유인가요?" 다이얼로그.
///
/// 로그인/새 기기 인증이 끝나 기기가 이미 신뢰된 뒤에 묻는다.
/// 목적은 **생체·간편로그인 설정을 유도할지** 결정하는 것이며,
/// 기기 신뢰 여부 자체를 바꾸지는 않는다.
///
/// 반환: true = 본인 기기(생체 설정 유도), false = 아니오/취소(건너뜀).
Future<bool> showOwnDeviceDialog(BuildContext context) async {
  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('본인 기기인가요?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
      content: const Text(
        '본인 소유의 기기라면 다음부터 생체·간편인증으로 더 빠르게 로그인할 수 있어요.\n'
        '공용 PC나 다른 사람의 기기라면 "아니오"를 선택해 주세요.',
        style: TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.gray600),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
          child: const Text('아니오'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal600, foregroundColor: Colors.white),
          child: const Text('예, 본인 기기예요'),
        ),
      ],
    ),
  );
  return res ?? false;
}
