import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../data/models/card_content_model.dart';

class CardContentSection extends StatelessWidget {
  final List<CardContentModel> contents;
  const CardContentSection({super.key, required this.contents});

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<CardContentModel>>{};
    for (final c in contents) {
      grouped.putIfAbsent(c.contentType, () => []).add(c);
    }
    return Column(
      children: grouped.entries
          .map((e) => _ContentGroup(type: e.key, items: e.value))
          .toList(),
    );
  }
}

class _ContentGroup extends StatelessWidget {
  final String type;
  final List<CardContentModel> items;

  const _ContentGroup({required this.type, required this.items});

  static const _labels = {
    'INTRO': '상품소개',
    'GUIDE': '발급안내',
    'NOTICE': '유의사항',
  };

  @override
  Widget build(BuildContext context) => ExpansionTile(
    title: Text(
      _labels[type] ?? type,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    ),
    initiallyExpanded: type == 'INTRO',
    children: items.map((c) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Html(data: c.mobileContentHtml ?? c.contentHtml),
    )).toList(),
  );
}