// 홈 '내 카드' — 보유 카드를 좌우로 슬라이드하는 이미지 카루셀.
//  - 카드 앞면 이미지(cardImageUrl) + 카드명 + 발급일 표시
//  - 좌우로 넘기며(PageView) 페이지 인디케이터(dots)
//  - 카드 탭 → 보유 카드 상세(/mypage/cards/:id)
//  - 보유 카드가 없으면 신청 유도, 신청 진행 건이 있으면 하단에 신청 현황 표시

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../mypage/presentation/providers/mypage_provider.dart';

class HomeCardCarousel extends ConsumerStatefulWidget {
  const HomeCardCarousel({super.key});

  @override
  ConsumerState<HomeCardCarousel> createState() => _HomeCardCarouselState();
}

class _HomeCardCarouselState extends ConsumerState<HomeCardCarousel> {
  final _controller = PageController(viewportFraction: 0.86);
  int _page = 0;

  static const double _cardHeight = 196; // 신용카드 비율(≈1.586:1) 기준

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  static List<Map<String, dynamic>> _asList(Object? v) =>
      (v as List? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(myCardsProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '내 카드',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal600,
                letterSpacing: 0.3,
              ),
            ),
          ),
          async.when(
            loading: () => const SizedBox(
              height: _cardHeight,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => _MessageBox(
              icon: Icons.error_outline,
              message: '카드 정보를 불러오지 못했습니다.',
            ),
            data: (data) {
              final owned = _asList(data['ownedCards']);
              final applied =
                  _asList(data['applications'] ?? data['appliedCards']);

              if (owned.isEmpty && applied.isEmpty) {
                return _EmptyCard(onTap: () => context.go('/search'));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (owned.isNotEmpty) ...[
                    SizedBox(
                      height: _cardHeight,
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: owned.length,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemBuilder: (_, i) => _CardFace(card: owned[i]),
                      ),
                    ),
                    if (owned.length > 1) ...[
                      const SizedBox(height: 10),
                      _Dots(count: owned.length, active: _page),
                    ],
                  ] else
                    _MessageBox(
                      icon: Icons.credit_card_off_outlined,
                      message: '보유한 카드가 없습니다.',
                    ),

                  // ── 신청 현황 ──────────────────────────────────
                  if (applied.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 6),
                      child: Text('신청 현황',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray600)),
                    ),
                    ...applied.map((a) => _AppliedRow(app: a)),
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

/// 카드 앞면 — 이미지(없으면 teal 그라데이션) + 카드명/발급일 오버레이
class _CardFace extends StatelessWidget {
  final Map<String, dynamic> card;
  const _CardFace({required this.card});

  @override
  Widget build(BuildContext context) {
    final name = card['cardName'] as String? ?? '카드';
    final imageUrl = card['cardImageUrl'] as String?;
    final userCardId = (card['userCardId'] as num?)?.toInt();
    final issuedAt = card['issuedAt']?.toString();

    return GestureDetector(
      onTap: userCardId == null
          ? null
          : () => context.push('/mypage/cards/$userCardId'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경 — 이미지 or 그라데이션
              if (imageUrl != null && imageUrl.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => const _GradientBg(),
                  errorWidget: (_, __, ___) => const _GradientBg(),
                )
              else
                const _GradientBg(),

              // 하단 가독성 스크림
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black54],
                    stops: [0.55, 1.0],
                  ),
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (issuedAt != null && issuedAt.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        '발급 ${_fmtDate(issuedAt)}',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _fmtDate(String v) {
    final d = DateTime.tryParse(v);
    if (d == null) return v;
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}.${two(d.month)}.${two(d.day)}';
  }
}

class _GradientBg extends StatelessWidget {
  const _GradientBg();
  @override
  Widget build(BuildContext context) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.teal900, AppColors.teal600, AppColors.teal400],
            stops: [0.0, 0.6, 1.0],
          ),
        ),
        child: Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Icon(Icons.credit_card, color: Colors.white24, size: 40),
          ),
        ),
      );
}

class _Dots extends StatelessWidget {
  final int count;
  final int active;
  const _Dots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active == i ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active == i ? AppColors.teal600 : AppColors.gray200,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

/// 신청 현황 한 줄 — 카드명 + 상태칩, 서류검토중이면 재제출 버튼
class _AppliedRow extends StatelessWidget {
  final Map<String, dynamic> app;
  const _AppliedRow({required this.app});

  @override
  Widget build(BuildContext context) {
    final name = app['cardName'] as String? ?? '카드';
    final status = app['applicationStatus'] as String? ??
        app['statusCode'] as String? ??
        '';
    final appId = (app['creditAppId'] as num?)?.toInt() ??
        (app['appId'] as num?)?.toInt() ??
        (app['applicationId'] as num?)?.toInt();

    final reviewing = status == 'REVIEWING' && appId != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.teal800,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: const Icon(Icons.credit_card,
                    size: 13, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(name,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w500)),
              ),
              Text(_statusLabel(status),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(status))),
            ],
          ),
          if (reviewing) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    context.push('/application/credit/$appId/documents'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('서류 재제출'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _statusLabel(String s) => switch (s) {
        'DRAFT' => '임시저장',
        'REQUESTED' => '신청접수',
        'REVIEWING' => '서류검토중',
        'SUBMITTED' => '심사중',
        'APPROVED' => '승인완료',
        'REJECTED' => '반려',
        'ISSUED' => '발급완료',
        _ => s,
      };

  static Color _statusColor(String s) => switch (s) {
        'APPROVED' || 'ISSUED' => AppColors.teal600,
        'REJECTED' => Colors.red,
        'REVIEWING' => const Color(0xFFF59E0B),
        _ => AppColors.gray400,
      };
}

class _EmptyCard extends StatelessWidget {
  final VoidCallback onTap;
  const _EmptyCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_card_outlined, size: 30, color: AppColors.teal600),
            SizedBox(height: 8),
            Text('보유한 카드가 없어요 · 카드 신청하러 가기',
                style: TextStyle(fontSize: 13, color: AppColors.gray600)),
          ],
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final IconData icon;
  final String message;
  const _MessageBox({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 28, color: AppColors.gray400),
            const SizedBox(height: 8),
            Text(message,
                style: const TextStyle(color: AppColors.gray400, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
