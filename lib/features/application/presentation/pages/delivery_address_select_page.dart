// 카드 배송지 선택 — 마이페이지에 등록한 주소 중에서 고른다.
//  - 기본 배송지를 자동 선택
//  - '이 주소로 배송' → 선택한 주소를 호출 측(step4)으로 pop 반환
//  - 등록 주소가 없으면 주소 관리 화면으로 유도
//  - BnkAppBar 기본 뒤로가기(pop) → 선택 취소(이전 화면 유지)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../mypage/data/models/address_model.dart';
import '../../../mypage/presentation/providers/mypage_provider.dart';

class DeliveryAddressSelectPage extends ConsumerStatefulWidget {
  /// 이미 선택돼 있던 배송지 id (재진입 시 해당 항목을 선택 상태로 표시)
  final int? selectedAddressId;
  const DeliveryAddressSelectPage({super.key, this.selectedAddressId});

  @override
  ConsumerState<DeliveryAddressSelectPage> createState() =>
      _DeliveryAddressSelectPageState();
}

class _DeliveryAddressSelectPageState
    extends ConsumerState<DeliveryAddressSelectPage> {
  int? _selectedId;
  bool _seeded = false;

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '배송지 선택'),
      body: SafeArea(
        child: async.when(
          loading: () =>
              const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          error: (_, __) => _Error(onRetry: () => ref.invalidate(addressesProvider)),
          data: (list) {
            if (list.isEmpty) return const _Empty();

            // 최초 1회: 기존 선택 → 기본배송지 → 첫 항목 순으로 자동 선택
            if (!_seeded) {
              _selectedId = widget.selectedAddressId ??
                  list.firstWhere((a) => a.isDefault, orElse: () => list.first)
                      .addressId;
              _seeded = true;
            }

            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    children: [
                      ...list.map((a) => _AddressOption(
                            address: a,
                            selected: a.addressId == _selectedId,
                            onTap: () =>
                                setState(() => _selectedId = a.addressId),
                          )),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => context.push('/mypage/addresses'),
                          icon: const Icon(Icons.add, size: 18),
                          style: TextButton.styleFrom(
                              foregroundColor: AppColors.teal600),
                          label: const Text('주소 추가 · 관리'),
                        ),
                      ),
                    ],
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedId == null
                            ? null
                            : () {
                                final picked = list.firstWhere(
                                    (a) => a.addressId == _selectedId);
                                context.pop(picked);
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('이 주소로 배송',
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AddressOption extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  const _AddressOption(
      {required this.address, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.teal600 : AppColors.gray200,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: selected ? AppColors.teal600 : AppColors.gray400,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          address.alias?.isNotEmpty == true
                              ? address.alias!
                              : '내 주소',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: AppColors.teal50,
                              borderRadius: BorderRadius.circular(6)),
                          child: const Text('기본',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.teal600)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address.fullAddress.isEmpty ? '-' : address.fullAddress,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.gray800, height: 1.4),
                  ),
                  if (address.zipcode?.isNotEmpty == true) ...[
                    const SizedBox(height: 2),
                    Text('(${address.zipcode})',
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.gray400)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_off_outlined,
              size: 40, color: AppColors.gray400),
          const SizedBox(height: 12),
          const Text('등록된 배송지가 없습니다.',
              style: TextStyle(color: AppColors.gray600)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.push('/mypage/addresses'),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: Colors.white),
            child: const Text('주소 등록하러 가기'),
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final VoidCallback onRetry;
  const _Error({required this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('배송지를 불러올 수 없습니다.',
              style: TextStyle(color: AppColors.gray400)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}
