import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/mypage_provider.dart';

/// 내 카드(보유 / 신청 현황) 탭 섹션 — 홈·마이페이지 공용.
///
/// 자체적으로 [TabController] 를 관리하고 [myCardsProvider] 를 구독한다.
/// 흰 카드 래퍼는 호출 측(_Section / 홈의 카드)에서 감싸므로 여기서는 내용만 반환.
class MyCardsSection extends ConsumerStatefulWidget {
  const MyCardsSection({super.key});

  @override
  ConsumerState<MyCardsSection> createState() => _MyCardsSectionState();
}

class _MyCardsSectionState extends ConsumerState<MyCardsSection>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardsAsync = ref.watch(myCardsProvider);

    return Column(
      children: [
        TabBar(
          controller: _tabController,
          labelColor: AppColors.teal600,
          unselectedLabelColor: AppColors.gray400,
          indicatorColor: AppColors.teal600,
          indicatorWeight: 2,
          tabs: const [
            Tab(text: '보유 카드'),
            Tab(text: '신청 현황'),
          ],
        ),
        SizedBox(
          height: 220,
          child: cardsAsync.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => const Center(
                child: Text('불러오지 못했습니다.',
                    style: TextStyle(color: AppColors.gray400))),
            data: (data) {
              final owned = _asList(data['ownedCards']);
              final applied =
                  _asList(data['applications'] ?? data['appliedCards']);
              return TabBarView(
                controller: _tabController,
                children: [
                  _OwnedList(items: owned),
                  _AppliedList(items: applied),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  static List<Map<String, dynamic>> _asList(Object? v) =>
      (v as List? ?? const [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
}

class _OwnedList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _OwnedList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCards(
        icon: Icons.credit_card_off_outlined,
        message: '보유 카드가 없습니다.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.gray100),
      itemBuilder: (context, i) {
        final c = items[i];
        final userCardId = (c['userCardId'] as num?)?.toInt();
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _CardChip(),
          title: Text(
            c['cardName'] as String? ?? '카드',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          trailing: const Icon(Icons.chevron_right,
              size: 18, color: AppColors.gray400),
          dense: true,
          onTap: userCardId == null
              ? null
              : () => context.push('/mypage/cards/$userCardId'),
        );
      },
    );
  }
}

class _AppliedList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  const _AppliedList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const _EmptyCards(
        icon: Icons.assignment_outlined,
        message: '신청 이력이 없습니다.',
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: items.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.gray100),
      itemBuilder: (context, i) {
        final c = items[i];
        final status = c['applicationStatus'] as String? ??
            c['statusCode'] as String? ??
            '';
        final creditAppId = (c['creditAppId'] as num?)?.toInt() ??
            (c['appId'] as num?)?.toInt();

        if (status == 'REVIEWING' && creditAppId != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                border: Border.all(color: const Color(0xFFFFE082)),
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const _CardChip(),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          c['cardName'] as String? ?? '카드',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w500),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('서류검토중',
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '추가 서류 제출이 필요합니다. 서류를 재제출하여 심사를 계속 진행하세요.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E)),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context
                          .push('/application/credit/$creditAppId/documents'),
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
              ),
            ),
          );
        }

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const _CardChip(),
          title: Text(
            c['cardName'] as String? ?? '카드',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            _statusLabel(status),
            style: TextStyle(fontSize: 11, color: _statusColor(status)),
          ),
          dense: true,
        );
      },
    );
  }

  static String _statusLabel(String s) => switch (s) {
        'DRAFT' => '임시저장',
        'REQUESTED' => '신청접수',
        'REVIEWING' => '심사중',
        'SUBMITTED' => '심사중',
        'APPROVED' => '승인완료',
        'REJECTED' => '반려',
        'ISSUED' => '발급완료',
        _ => s,
      };

  static Color _statusColor(String s) => switch (s) {
        'APPROVED' || 'ISSUED' => AppColors.teal600,
        'REJECTED' => Colors.red,
        _ => AppColors.gray400,
      };
}

class _CardChip extends StatelessWidget {
  const _CardChip();
  @override
  Widget build(BuildContext context) => Container(
        width: 40,
        height: 26,
        decoration: BoxDecoration(
          color: AppColors.teal800,
          borderRadius: BorderRadius.circular(5),
        ),
        child: const Icon(Icons.credit_card, size: 14, color: Colors.white),
      );
}

class _EmptyCards extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyCards({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: AppColors.gray400),
          const SizedBox(height: 8),
          Text(message, style: const TextStyle(color: AppColors.gray400)),
        ],
      ),
    );
  }
}
