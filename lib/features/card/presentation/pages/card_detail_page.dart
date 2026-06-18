import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/format_util.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/bnk_error_view.dart';
import '../providers/card_detail_provider.dart';
import '../providers/card_compare_provider.dart';

class CardDetailPage extends ConsumerWidget {
  final int cardId;
  const CardDetailPage({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async       = ref.watch(cardDetailProvider(cardId));
    final compareIds  = ref.watch(cardCompareProvider);
    final isComparing = compareIds.contains(cardId);

    return Scaffold(
      appBar: BnkAppBar(
        title: '카드 상세',
        actions: [
          IconButton(
            tooltip: isComparing ? '비교 취소' : '비교 담기',
            icon: Icon(
              isComparing
                  ? Icons.compare_arrows
                  : Icons.add_chart_outlined,
              color: isComparing ? AppColors.primary : null,
            ),
            onPressed: () =>
                ref.read(cardCompareProvider.notifier).toggle(cardId),
          ),
        ],
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => BnkErrorView(
          message: '카드 정보를 불러오지 못했습니다.',
          onRetry: () => ref.invalidate(cardDetailProvider(cardId)),
        ),
        data: (card) => _CardDetailBody(card: card),
      ),
      bottomNavigationBar: _ApplyBar(cardId: cardId),
    );
  }
}

// ── 본문 ─────────────────────────────────────────────────────────

class _CardDetailBody extends StatelessWidget {
  final Map<String, dynamic> card;
  const _CardDetailBody({required this.card});

  @override
  Widget build(BuildContext context) {
    final images =
        (card['images'] as List?)?.cast<Map<String, dynamic>>() ?? [];

    return ListView(
      children: [
        if (images.isNotEmpty)
          CarouselSlider(
            options: CarouselOptions(height: 200, enlargeCenterPage: true),
            items: images.map((img) {
              final url = img['imageUrl'] as String? ?? '';
              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
              );
            }).toList(),
          )
        else
          Container(
            height: 200,
            color: AppColors.primary.withValues(alpha: 0.08),
            child: const Icon(Icons.credit_card,
                size: 80, color: AppColors.primary),
          ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card['cardName'] as String? ?? '',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                card['companyName'] as String? ?? '',
                style:
                const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                label: '국내 연회비',
                value: FormatUtil.wonOrFree(
                    card['annualFeeDomestic'] as int? ?? 0),
              ),
              if ((card['annualFeeOverseas'] as int? ?? 0) > 0)
                _InfoRow(
                  label: '해외 연회비',
                  value: FormatUtil.won(
                      card['annualFeeOverseas'] as int),
                ),
              const Divider(height: 32),
              if (card['topBenefit'] != null) ...[
                const Text('주요 혜택',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Text(card['topBenefit'] as String,
                    style: const TextStyle(
                        color: AppColors.textMuted, height: 1.5)),
                const Divider(height: 32),
              ],
              if (card['mobileContentHtml'] != null) ...[
                const Text('상세 내용',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Html(data: card['mobileContentHtml'] as String),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textMuted)),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    ),
  );
}

// ── 하단 신청 바 ──────────────────────────────────────────────────

class _ApplyBar extends StatelessWidget {
  final int cardId;
  const _ApplyBar({required this.cardId});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.go('/cards/compare'),
              child: const Text('카드 비교'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // TODO: 카드 신청 플로우 연결
              },
              child: const Text('카드 신청',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    ),
  );
}