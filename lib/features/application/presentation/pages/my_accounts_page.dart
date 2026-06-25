import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../providers/account_provider.dart'; // AccountModel/myAccountsProvider 재공개됨

/// #14 내 계좌 목록 화면.
/// 라우트: GoRoute(path: '/mypage/accounts', builder: (_, __) => const MyAccountsPage())
class MyAccountsPage extends ConsumerWidget {
  const MyAccountsPage({super.key});

  static const _typeLabel = {
    'CHECKING': '입출금',
    'SAVINGS': '적금',
    'DEPOSIT': '예금',
  };

  /// 계좌 개설로 이동 후 돌아오면 목록을 갱신한다.
  Future<void> _openCreate(BuildContext context, WidgetRef ref) async {
    await context.push('/accounts/create');
    ref.invalidate(myAccountsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAccountsProvider);
    final fmt = NumberFormat('#,###');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BnkAppBar(
        title: '내 계좌',
        backPath: '/mypage',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: '계좌 개설',
            onPressed: () => _openCreate(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.teal600,
        onRefresh: () async => ref.invalidate(myAccountsProvider),
        child: async.when(
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.teal600)),
          error: (_, __) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              SizedBox(height: 120),
              Center(child: Text('계좌를 불러오지 못했습니다.')),
            ],
          ),
          data: (list) {
            if (list.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 100),
                  const Icon(Icons.account_balance_outlined,
                      size: 48, color: AppColors.gray400),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text('개설된 계좌가 없습니다.',
                        style: TextStyle(color: AppColors.gray600)),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _openCreate(context, ref),
                      icon: const Icon(Icons.add),
                      label: const Text('계좌 개설하기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final a = list[i];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.teal50,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _typeLabel[a.accountType] ?? a.accountType,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.teal800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              a.displayName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 15),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.accountNumber,
                        style: const TextStyle(
                            color: AppColors.gray600, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${fmt.format(a.balance)}원',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}