import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class MyCardCarousel extends StatefulWidget {
  const MyCardCarousel({super.key});

  @override
  State<MyCardCarousel> createState() => _MyCardCarouselState();
}

class _MyCardCarouselState extends State<MyCardCarousel> {
  int _currentPage = 0;

  final List<Map<String, String>> _cards = [
    {'name': 'BNK 다이나믹 카드', 'number': '**** **** **** 3721', 'brand': 'VISA'},
    {'name': 'BNK 그린 체크카드', 'number': '**** **** **** 8842', 'brand': 'Master'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.teal900, AppColors.teal600, AppColors.teal400],
          stops: [0.0, 0.6, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 카드',
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 130,
            child: PageView.builder(
              itemCount: _cards.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, i) => _CardItem(card: _cards[i]),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _cards.length,
                  (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: _currentPage == i ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: _currentPage == i
                      ? Colors.white
                      : Colors.white38,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final Map<String, String> card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: AppColors.teal800,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 28, height: 20,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A843),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Text(
                card['brand']!,
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card['number']!,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                card['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}