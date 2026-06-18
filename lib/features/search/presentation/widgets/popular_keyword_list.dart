import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/search_provider.dart';

class PopularKeywordList extends ConsumerWidget {
  final void Function(String keyword) onTap;
  const PopularKeywordList({super.key, required this.onTap});

  @override Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(popularKeywordsProvider);
    return async.when(
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => const Text('인기 검색어를 불러오지 못했습니다.'),
      data: (list) => Column(children: list.take(10).toList().asMap().entries.map((e) {
        final keyword = (e.value as Map)['keyword'] as String;
        return ListTile(
          leading: Text('${e.key + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
          title: Text(keyword),
          onTap: () => onTap(keyword),
        );
      }).toList()),
    );
  }
}
