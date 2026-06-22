import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../mypage/presentation/providers/mypage_provider.dart';

class MyCardCarousel extends ConsumerStatefulWidget {
  const MyCardCarousel({super.key});

  @override
  ConsumerState<MyCardCarousel> createState() => _MyCardCarouselState();
}

class _MyCardCarouselState extends ConsumerState<MyCardCarousel> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final myCardsAsync = ref.watch(myCardsProvider);

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
          myCardsAsync.when(
            loading: () => const SizedBox(
              height: 130,
              child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white70),
              ),
            ),
            error: (_, __) => const SizedBox(
              height: 130,
              child: Center(
                child: Text('카드 정보를 불러오지 못했습니다.',
                    style: TextStyle(color: Colors.white70, fontSize: 12)),
              ),
            ),
            data: (data) {
              final ownedCards = (data['ownedCards'] as List? ?? [])
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();

              if (ownedCards.isEmpty) {
                return SizedBox(
                  height: 130,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.credit_card_off_outlined,
                            color: Colors.white54, size: 28),
                        SizedBox(height: 8),
                        Text('보유한 카드가 없습니다',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 130,
                    child: PageView.builder(
                      itemCount: ownedCards.length,
                      physics: const BouncingScrollPhysics(),
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemBuilder: (context, i) =>
                          _CardItem(card: ownedCards[i]),
                    ),
                  ),
                  if (ownedCards.length > 1) ...[
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        ownedCards.length,
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
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CardItem extends StatelessWidget {
  final Map<String, dynamic> card;
  const _CardItem({required this.card});

  @override
  Widget build(BuildContext context) {
    final cardName = card['cardName'] as String? ?? '카드';

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
            ],
          ),
          Text(
            cardName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}