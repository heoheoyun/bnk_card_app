import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';

class GuestHomeBody extends StatelessWidget {
  const GuestHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _GuestHero(),
        const SizedBox(height: 8),
        _PreviewLabel(),
        _PreviewCard(
          color: AppColors.teal800,
          name: 'BNK 다이나믹 카드',
          desc: '외식·쇼핑 최대 7% 할인',
          badge: '신용',
        ),
        _PreviewCard(
          color: AppColors.teal600,
          name: 'BNK 그린 체크카드',
          desc: '대중교통·편의점 적립',
          badge: '체크',
        ),
        _PreviewCard(
          color: AppColors.teal400,
          name: 'BNK 프리미엄 카드',
          desc: '공항라운지·호텔 혜택',
          badge: '신용',
        ),
        const SizedBox(height: 8),
        _ChatHint(),
      ],
    );
  }
}

class _GuestHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(height: 20),
          const Text(
            '카드 혜택, 한눈에',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '로그인하고 내 카드 이용금액과\n맞춤 혜택을 확인해보세요',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.teal600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '로그인',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => context.go('/signup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                '회원가입',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '인기 카드 상품',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Color color;
  final String name;
  final String desc;
  final String badge;

  const _PreviewCard({
    required this.color,
    required this.name,
    required this.desc,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.credit_card,
              color: Colors.white54,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.teal50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.teal800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Icon(
            Icons.smart_toy_outlined,
            color: AppColors.teal600,
            size: 22,
          ),
          const SizedBox(width: 10),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 12, color: AppColors.gray600),
              children: [
                TextSpan(
                  text: 'AI 챗봇',
                  style: TextStyle(
                    color: AppColors.teal600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(text: '으로 내게 맞는 카드를 추천받아보세요'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}