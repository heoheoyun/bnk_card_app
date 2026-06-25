import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/account_provider.dart';

/// #14 (선택) — 마이페이지/홈에 끼워넣는 '내 계좌' 미리보기 섹션.
/// 사용: 본문 Column/ListView 에 `const AccountMenuSection()` 한 줄 추가.
/// 진입만 필요하면 마이페이지 '금융' 섹션의 '내 계좌' 메뉴 타일로 충분하다.
class AccountMenuSection extends ConsumerWidget {
  const AccountMenuSection({super.key, this.previewCount = 2});

  final int previewCount;

  static const _typeLabel = {
    'CHECKING': '입출금',
    'SAVINGS': '적금',
    'DEPOSIT': '예금',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(myAccountsProvider);
    final fmt = NumberFormat('#,###');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, left: 4),
            child: Row(
              children: [
                const Text('내 계좌',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray800)),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/mypage/accounts'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text('전체 보기 ',
                      style: TextStyle(fontSize: 12, color: AppColors.teal600)),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: async.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.teal600),
                  ),
                ),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                child: Text('계좌를 불러오지 못했습니다.',
                    style: TextStyle(fontSize: 13, color: AppColors.gray600)),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return InkWell(
                    onTap: () => context.push('/mypage/accounts'),
                    borderRadius: BorderRadius.circular(14),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_outlined,
                              size: 20, color: AppColors.gray400),
                          SizedBox(width: 12),
                          Text('개설된 계좌가 없습니다.',
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.gray600)),
                          Spacer(),
                          Icon(Icons.chevron_right,
                              size: 20, color: AppColors.gray400),
                        ],
                      ),
                    ),
                  );
                }
                final preview = list.take(previewCount).toList();
                return Column(
                  children: [
                    for (var i = 0; i < preview.length; i++) ...[
                      if (i > 0)
                        const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                            color: AppColors.gray100),
                      InkWell(
                        onTap: () => context.push('/mypage/accounts'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: AppColors.teal50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.account_balance,
                                    size: 18, color: AppColors.teal600),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _typeLabel[preview[i].accountType] ??
                                          preview[i].displayName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      preview[i].accountNumber,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.gray600),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${fmt.format(preview[i].balance)}원',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.teal600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
