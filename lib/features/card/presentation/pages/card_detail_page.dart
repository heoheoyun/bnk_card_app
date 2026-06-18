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
import '../../domain/entities/card_detail.dart';
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
              isComparing ? Icons.compare_arrows : Icons.add_chart_outlined,
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
        // ★ data 타입: CardDetail Entity — Map 접근 전면 제거
        data: (card) => _CardDetailBody(card: card),
      ),
      bottomNavigationBar: _ApplyBar(cardId: cardId),
    );
  }
}

// ── 본문 ──────────────────────────────────────────────────────────

class _CardDetailBody extends StatelessWidget {
  final CardDetail card;
  const _CardDetailBody({required this.card});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ── 이미지 캐러셀 ────────────────────────────────────────
        if (card.images.isNotEmpty)
          CarouselSlider(
            options: CarouselOptions(height: 200, enlargeCenterPage: true),
            items: card.images.map((img) {
              return CachedNetworkImage(
                imageUrl: img.imageUrl,
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                const Center(child: CircularProgressIndicator()),
                errorWidget: (_, __, ___) =>
                const Icon(Icons.broken_image, size: 48),
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

        // ── 기본 정보 ────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                card.cardName,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                card.companyName,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              _InfoRow(
                label: '국내 연회비',
                value: FormatUtil.wonOrFree(card.annualFeeDomestic),
              ),
              if (card.annualFeeOverseas > 0)
                _InfoRow(
                  label: '해외 연회비',
                  value: FormatUtil.won(card.annualFeeOverseas),
                ),
              if (card.previousMonthSpend > 0)
                _InfoRow(
                  label: '전월 실적',
                  value: FormatUtil.won(card.previousMonthSpend),
                ),
              if (card.summaryDescription != null) ...[
                const Divider(height: 32),
                Text(
                  card.summaryDescription!,
                  style: const TextStyle(
                      color: AppColors.textMuted, height: 1.6),
                ),
              ],
            ],
          ),
        ),

        // ── 혜택 목록 ────────────────────────────────────────────
        if (card.benefits.isNotEmpty) ...[
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Text('혜택',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          ...card.benefits.map((b) => ListTile(
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.star_outline,
                  color: AppColors.primary, size: 18),
            ),
            title: Text(b.benefitTitle,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
            subtitle: Text(b.displayText,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary)),
            dense: true,
          )),
        ],

        // ── 콘텐츠 (INTRO / GUIDE / NOTICE) ─────────────────────
        if (card.contents.isNotEmpty) ...[
          const Divider(height: 1),
          ...card.contents.map((c) => ExpansionTile(
            title: Text(
              _contentLabel(c.contentType),
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 15),
            ),
            initiallyExpanded: c.contentType == 'INTRO',
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 4),
                child: Html(
                    data: c.mobileContentHtml ?? c.contentHtml ?? ''),
              ),
            ],
          )),
        ],

        const SizedBox(height: 32),
      ],
    );
  }

  static String _contentLabel(String type) => switch (type) {
    'INTRO'  => '상품 소개',
    'GUIDE'  => '발급 안내',
    'NOTICE' => '유의사항',
    _        => type,
  };
}

// ── 정보 행 ──────────────────────────────────────────────────────

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