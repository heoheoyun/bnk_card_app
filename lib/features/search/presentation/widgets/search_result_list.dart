import 'package:flutter/material.dart';
import '../../../card/presentation/widgets/card_list_item.dart';

class SearchResultList extends StatelessWidget {
  final List<dynamic> results;
  final int totalCount;
  const SearchResultList({super.key, required this.results, required this.totalCount});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Text('검색 결과 $totalCount건', style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13)),
      ),
      ...results.map((r) => CardListItem(card: r as Map<String, dynamic>)),
    ],
  );
}
