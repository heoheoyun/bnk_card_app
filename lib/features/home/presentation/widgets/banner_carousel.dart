import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/banner_model.dart';
import '../../../../core/constants/app_colors.dart';

class BannerCarousel extends StatefulWidget {
  final List<BannerModel> banners;
  const BannerCarousel({super.key, required this.banners});
  @override State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  int _current = 0;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      CarouselSlider(
        options: CarouselOptions(
          height: 180,
          autoPlay: true,
          viewportFraction: 1.0,
          onPageChanged: (i, _) => setState(() => _current = i),
        ),
        items: widget.banners.map((b) => GestureDetector(
          onTap: () => context.push('/cards/${b.cardId}'),
          child: Stack(fit: StackFit.expand, children: [
            if (b.imageUrl != null)
              CachedNetworkImage(imageUrl: b.imageUrl!, fit: BoxFit.cover)
            else
              Container(color: AppColors.primary),
            Positioned(bottom: 16, left: 16, child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b.cardName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                if (b.benefitSummary != null)
                  Text(b.benefitSummary!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            )),
          ]),
        )).toList(),
      ),
      // 인디케이터
      Row(mainAxisAlignment: MainAxisAlignment.center, children: widget.banners.asMap().entries.map((e) =>
        Container(
          width: _current == e.key ? 16 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: _current == e.key ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
      ).toList()),
    ],
  );
}
