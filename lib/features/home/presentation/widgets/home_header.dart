import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../mypage/presentation/providers/mypage_provider.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myInfoAsync       = ref.watch(myInfoProvider);
    final monthlyAsync      = ref.watch(monthlySpendingProvider);

    final name         = myInfoAsync.valueOrNull?['name'] as String? ?? '';
    final totalAmount  = (monthlyAsync.valueOrNull?['totalAmount'] as num?)?.toInt() ?? 0;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.teal900, AppColors.teal600, AppColors.teal400],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BNK 부산은행',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.white, size: 22),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white24,
                  padding: const EdgeInsets.all(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name.isNotEmpty ? '$name 님, 이번달 총 이용금액' : '이번달 총 이용금액',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          monthlyAsync.when(
            loading: () => const SizedBox(
              height: 40,
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white70),
              ),
            ),
            error: (_, __) => const Text(
              '0원',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w500,
                letterSpacing: -1,
              ),
            ),
            data: (_) => Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _formatAmount(totalAmount),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -1,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, left: 2),
                  child: Text(
                    '원',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }
}