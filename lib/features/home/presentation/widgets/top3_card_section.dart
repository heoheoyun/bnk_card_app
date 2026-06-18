import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/home_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';

class Top3CardSection extends ConsumerWidget {
  const Top3CardSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(homeTop3Provider(null));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error:   (e, _) => const SizedBox.shrink(),
      data:    (list) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text('맞춤 추천 카드 TOP 3', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          ...list.take(3).toList().asMap().entries.map((e) {
            final card = e.value as Map<String, dynamic>;
            final rank = e.key + 1;
            return _Top3CardTile(rank: rank, card: card);
          }),
        ],
      ),
    );
  }
}

class _Top3CardTile extends StatelessWidget {
  final int rank;
  final Map<String, dynamic> card;
  const _Top3CardTile({required this.rank, required this.card});

  @override
  Widget build(BuildContext context) => ListTile(
    leading: CircleAvatar(
      backgroundColor: rank == 1 ? const Color(0xFFFFD700) : rank == 2 ? Colors.grey.shade400 : const Color(0xFFCD7F32),
      child: Text('$rank', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
    title: Text(card['cardName'] as String? ?? ''),
    subtitle: Text(FormatUtil.wonOrFree((card['annualFeeDomestic'] as int? ?? 0))),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => context.go('/cards/${card['cardId']}'),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    tileColor: rank == 1 ? AppColors.primary.withValues(alpha: 0.04) : null,
  );
}