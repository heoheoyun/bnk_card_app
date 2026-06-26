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
import '../widgets/card_terms_section.dart';
class CardDetailPage extends ConsumerWidget {
  final int cardId;
  const CardDetailPage({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async       = ref.watch(cardDetailProvider(cardId));
    final compareIds  = ref.watch(cardCompareProvider);
    final isComparing = compareIds.contains(cardId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BnkAppBar(
        title: '카드 상세',
        actions: [
          IconButton(
            tooltip: isComparing ? '비교 취소' : '비교 담기',
            icon: Icon(
              isComparing ? Icons.compare_arrows : Icons.add_chart_outlined,
              color: isComparing ? Colors.white : Colors.white70,
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
      bottomNavigationBar: _ApplyBar(cardId: cardId, card: async.valueOrNull),
    );
  }
}

// ── 카드 타입별 스타일 헬퍼 ──────────────────────────────────────

class _CardTypeStyle {
  static String label(String type) => switch (type) {
    'CREDIT'  => '신용',
    'CHECK'   => '체크',
    'PREPAID' => '선불',
    _         => type,
  };

  static List<Color> gradient(String type) => switch (type) {
    'CREDIT'  => const [Color(0xFF003040), Color(0xFF00677F)],
    'CHECK'   => const [Color(0xFF2C3E42), Color(0xFF5C7A83)],
    'PREPAID' => const [Color(0xFF8A5A1E), Color(0xFFBA7517)],
    _         => const [AppColors.gray600, AppColors.gray400],
  };

  static Color badgeBg(String type) => switch (type) {
    'CREDIT'  => AppColors.teal50,
    'CHECK'   => AppColors.gray100,
    'PREPAID' => const Color(0xFFFCEFE0),
    _         => AppColors.gray100,
  };

  static Color badgeText(String type) => switch (type) {
    'CREDIT'  => AppColors.teal800,
    'CHECK'   => AppColors.gray600,
    'PREPAID' => const Color(0xFF8A5A1E),
    _         => AppColors.gray600,
  };
}

// ── 본문 ──────────────────────────────────────────────────────────

class _CardDetailBody extends StatelessWidget {
  final CardDetail card;
  const _CardDetailBody({required this.card});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // ── 카드 비주얼 헤더 ────────────────────────────────────
        Container(
          width: double.infinity,
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              if (card.images.isNotEmpty)
                SizedBox(
                  height: 150,
                  child: CarouselSlider(
                    options: CarouselOptions(
                      height: 150,
                      enlargeCenterPage: true,
                      viewportFraction: 0.5,
                    ),
                    items: card.images.map((img) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: img.imageUrl,
                          fit: BoxFit.contain,
                          placeholder: (_, __) =>
                          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                          errorWidget: (_, __, ___) => _CardFallbackVisual(card: card),
                        ),
                      );
                    }).toList(),
                  ),
                )
              else
                SizedBox(
                  width: 170,
                  child: AspectRatio(
                    aspectRatio: 1.586,
                    child: _CardFallbackVisual(card: card),
                  ),
                ),
            ],
          ),
        ),

        // ── 기본 정보 ────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: _CardTypeStyle.badgeBg(card.cardType),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _CardTypeStyle.label(card.cardType),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _CardTypeStyle.badgeText(card.cardType),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      card.companyName,
                      style: const TextStyle(fontSize: 10, color: AppColors.gray600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                card.cardName,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w500),
              ),
              if (card.summaryDescription != null) ...[
                const SizedBox(height: 6),
                Text(
                  card.summaryDescription!,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.gray400, height: 1.5),
                ),
              ],
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: _FeeStat(label: '국내 연회비',
                          value: FormatUtil.wonOrFree(card.annualFeeDomestic)),
                    ),
                    Container(width: 0.5, height: 28, color: AppColors.gray200),
                    Expanded(
                      child: _FeeStat(label: '해외 연회비',
                          value: card.annualFeeOverseas > 0
                              ? FormatUtil.won(card.annualFeeOverseas)
                              : '없음'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // ── 혜택 목록 ────────────────────────────────────────────
        if (card.benefits.isNotEmpty)
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('혜택',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 10),
                ...card.benefits.map((b) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.teal50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.star_outline,
                            color: AppColors.teal600, size: 14),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(b.benefitTitle,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 2),
                            Text(b.displayText,
                                style: const TextStyle(
                                    fontSize: 11, color: AppColors.gray400)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ),

        const SizedBox(height: 8),

        // ── 콘텐츠 (INTRO / GUIDE / NOTICE) ─────────────────────
        if (card.contents.isNotEmpty)
          Container(
            color: Colors.white,
            child: Column(
              children: card.contents.map((c) => _AccordionTile(
                title: c.title.isNotEmpty ? c.title : _contentLabel(c.contentType),
                initiallyExpanded: c.contentType == 'INTRO',
                child: Html(data: c.mobileContentHtml ?? c.contentHtml ?? ''),
              )).toList(),
            ),
          ),
        const SizedBox(height: 8),
        CardTermsSection(cardId: card.cardId),

        const SizedBox(height: 100),
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

class _CardFallbackVisual extends StatelessWidget {
  final CardDetail card;
  const _CardFallbackVisual({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _CardTypeStyle.gradient(card.cardType),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 24, height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A843),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          Text(
            card.cardName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _FeeStat extends StatelessWidget {
  final String label;
  final String value;
  const _FeeStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray400)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    ],
  );
}

class _AccordionTile extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;
  const _AccordionTile({
    required this.title, required this.child, this.initiallyExpanded = false,
  });

  @override
  State<_AccordionTile> createState() => _AccordionTileState();
}

class _AccordionTileState extends State<_AccordionTile> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.gray100, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Icon(_expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 18, color: AppColors.gray400),
              ],
            ),
          ),
        ),
        if (_expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: widget.child,
          ),
      ],
    );
  }
}

// ── 하단 신청 바 ──────────────────────────────────────────────────

class _ApplyBar extends StatelessWidget {
  final int cardId;
  final CardDetail? card;
  const _ApplyBar({required this.cardId, this.card});

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray200, width: 0.5)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          SizedBox(
            width: 48, height: 48,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
                side: const BorderSide(color: AppColors.gray200),
              ),
              onPressed: () => context.go('/cards/compare'),
              child: const Icon(Icons.compare_arrows, size: 18, color: AppColors.gray600),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                print('=== 신청 버튼 클릭 cardId=$cardId cardType=${card?.cardType} ===');
                if (card == null) return;
                if (card!.cardType == 'CREDIT') {
                  context.push('/application/credit/step1', extra: cardId);
                } else {
                  context.push('/application/check/step1', extra: cardId);
                }
              },
              child: const Text('카드 신청',
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            ),
          ),
        ],
      ),
    ),
  );
}