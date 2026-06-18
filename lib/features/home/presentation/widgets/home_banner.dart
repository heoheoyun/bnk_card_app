import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HomeBanner extends StatelessWidget {
  const HomeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.teal50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  '신규 카드 혜택 확인하기',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.teal800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '이번달 추천 카드 보러가기',
                  style: TextStyle(fontSize: 11, color: AppColors.teal600),
                ),
              ],
            ),
          ),
          Container(
            width: 28, height: 28,
            decoration: const BoxDecoration(
              color: AppColors.teal600,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_forward,
                color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}