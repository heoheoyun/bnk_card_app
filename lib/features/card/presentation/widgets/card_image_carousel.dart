import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../data/models/card_image_model.dart';

class CardImageCarousel extends StatefulWidget {
  final List<CardImageModel> images;
  const CardImageCarousel({super.key, required this.images});
  @override State<CardImageCarousel> createState() => _CardImageCarouselState();
}

class _CardImageCarouselState extends State<CardImageCarousel> {
  int _current = 0;

  List<CardImageModel> get _displayImages =>
      widget.images.where((i) => i.imageType == 'FRONT' || i.imageType == 'BACK').toList();

  @override
  Widget build(BuildContext context) {
    final imgs = _displayImages;
    if (imgs.isEmpty) return const SizedBox(height: 200, child: Center(child: Icon(Icons.credit_card, size: 64)));
    return Column(children: [
      CarouselSlider(
        options: CarouselOptions(
          height: 200,
          viewportFraction: 0.85,
          enableInfiniteScroll: imgs.length > 1,
          onPageChanged: (i, _) => setState(() => _current = i),
        ),
        items: imgs.map((img) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.hardEdge,
          child: CachedNetworkImage(imageUrl: img.imageUrl, fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(color: Colors.grey.shade200,
                  child: const Icon(Icons.credit_card, size: 48, color: Colors.grey))),
        )).toList(),
      ),
      if (imgs.length > 1)
        Row(mainAxisAlignment: MainAxisAlignment.center, children: imgs.asMap().entries.map((e) =>
          Container(
            width: _current == e.key ? 16 : 8, height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _current == e.key ? const Color(0xFF003087) : Colors.grey.shade300,
            ),
          ),
        ).toList()),
    ]);
  }
}
