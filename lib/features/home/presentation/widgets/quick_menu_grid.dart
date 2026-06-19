import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class QuickMenuGrid extends StatelessWidget {
  const QuickMenuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final menus = [
      {
        'icon': Icons.credit_card_outlined,
        'label': '카드 상품 보기',
        'onTap': () => context.go('/search'),
      },
      {
        'icon': Icons.smart_toy_outlined,
        'label': 'AI 챗봇',
        'onTap': () => context.go('/ai/chat'),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: menus
            .map((m) => Expanded(child: _QuickBtn(menu: m)))
            .expand((w) => [w, const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  final Map<String, dynamic> menu;
  const _QuickBtn({required this.menu});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: menu['onTap'] as VoidCallback,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(
                color: AppColors.teal50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(menu['icon'] as IconData,
                  color: AppColors.teal600, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              menu['label'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.gray800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}