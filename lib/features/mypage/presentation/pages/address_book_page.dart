// 배송지(주소록) 관리 — 다중 주소를 별칭과 함께 등록/관리.
//  - 등록된 주소 목록(기본 배송지 우선)
//  - 주소 추가(우편번호 검색 + 상세주소 + 별칭 + 기본배송지 지정)
//  - 별칭 수정 / 기본 배송지 설정 / 삭제
//
// 서버 계약:
//   GET    /api/users/me/addresses
//   POST   /api/users/me/addresses           { alias, zipcode, address, addressDetail, setDefault }
//   PATCH  /api/users/me/addresses/{id}       { alias }
//   PATCH  /api/users/me/addresses/{id}/default
//   DELETE /api/users/me/addresses/{id}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../../../shared/widgets/address_search_field.dart';
import '../../data/models/address_model.dart';
import '../providers/mypage_provider.dart';

const int _maxAddresses = 10;

class AddressBookPage extends ConsumerWidget {
  const AddressBookPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(addressesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '배송지 관리'),
      floatingActionButton: async.maybeWhen(
        data: (list) => list.length >= _maxAddresses
            ? null
            : FloatingActionButton.extended(
                backgroundColor: AppColors.teal600,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.add),
                label: const Text('주소 추가'),
                onPressed: () => _openAddSheet(context, ref),
              ),
        orElse: () => null,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal600,
          onRefresh: () async => ref.refresh(addressesProvider.future),
          child: async.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => _ErrorView(
                onRetry: () => ref.invalidate(addressesProvider)),
            data: (list) => _Body(items: list),
          ),
        ),
      ),
    );
  }

  static Future<void> _openAddSheet(BuildContext context, WidgetRef ref) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddAddressSheet(),
    );
    if (created == true) ref.invalidate(addressesProvider);
  }
}

class _Body extends StatelessWidget {
  final List<Address> items;
  const _Body({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 96,
      ),
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.teal50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.teal200),
          ),
          child: const Text(
            '카드 발급 시 배송지로 사용할 주소를 등록해 두세요.\n'
            '기본 배송지는 한 곳만 지정됩니다. (최대 10개)',
            style:
                TextStyle(fontSize: 12.5, color: AppColors.teal800, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.location_off_outlined,
                      size: 36, color: AppColors.gray400),
                  SizedBox(height: 10),
                  Text('등록된 주소가 없습니다.\n아래 + 버튼으로 추가해 주세요.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.gray400)),
                ],
              ),
            ),
          )
        else
          ...items.map((e) => _AddressCard(item: e)),
      ],
    );
  }
}

class _AddressCard extends ConsumerWidget {
  final Address item;
  const _AddressCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: item.isDefault
            ? Border.all(color: AppColors.teal600, width: 1.2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  item.alias?.isNotEmpty == true ? item.alias! : '내 주소',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              if (item.isDefault) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.teal50,
                      borderRadius: BorderRadius.circular(6)),
                  child: const Text('기본 배송지',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.teal600)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.fullAddress.isEmpty ? '-' : item.fullAddress,
            style: const TextStyle(
                fontSize: 13, color: AppColors.gray800, height: 1.4),
          ),
          if (item.zipcode?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text('(${item.zipcode})',
                style:
                    const TextStyle(fontSize: 11.5, color: AppColors.gray400)),
          ],
          const Divider(height: 20, color: AppColors.gray100),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!item.isDefault)
                TextButton(
                  onPressed: () => _setDefault(context, ref),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.teal600,
                      visualDensity: VisualDensity.compact),
                  child: const Text('기본으로 설정',
                      style: TextStyle(fontSize: 13)),
                ),
              TextButton.icon(
                onPressed: () => _editAlias(context, ref),
                icon: const Icon(Icons.edit_outlined, size: 16),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.gray600,
                    visualDensity: VisualDensity.compact),
                label: const Text('별칭', style: TextStyle(fontSize: 13)),
              ),
              TextButton.icon(
                onPressed: () => _confirmDelete(context, ref),
                icon: const Icon(Icons.delete_outline, size: 16),
                style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                    visualDensity: VisualDensity.compact),
                label: const Text('삭제', style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _setDefault(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(mypageDatasourceProvider).setDefaultAddress(item.addressId);
      ref.invalidate(addressesProvider);
      messenger.showSnackBar(
          const SnackBar(content: Text('기본 배송지로 설정되었습니다.')));
    } catch (_) {
      messenger
          .showSnackBar(const SnackBar(content: Text('설정에 실패했습니다.')));
    }
  }

  Future<void> _editAlias(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: item.alias ?? '');
    final messenger = ScaffoldMessenger.of(context);
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('별칭 수정', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          maxLength: 100,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '예: 집, 회사',
            counterText: '',
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    const BorderSide(color: AppColors.teal600, width: 1.2)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
              child: const Text('취소')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: Colors.white),
              child: const Text('저장')),
        ],
      ),
    );
    if (saved != true) return;
    final name = ctrl.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('별칭을 입력해 주세요.')));
      return;
    }
    try {
      await ref
          .read(mypageDatasourceProvider)
          .updateAddressAlias(item.addressId, name);
      ref.invalidate(addressesProvider);
      messenger
          .showSnackBar(const SnackBar(content: Text('별칭이 수정되었습니다.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('수정에 실패했습니다.')));
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('주소 삭제', style: TextStyle(fontSize: 16)),
        content: const Text('이 주소를 삭제하시겠습니까?',
            style: TextStyle(fontSize: 13, height: 1.5)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
              child: const Text('취소')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, foregroundColor: Colors.white),
              child: const Text('삭제')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await ref.read(mypageDatasourceProvider).deleteAddress(item.addressId);
      ref.invalidate(addressesProvider);
      messenger.showSnackBar(const SnackBar(content: Text('주소가 삭제되었습니다.')));
    } on DioException catch (e) {
      final code =
          e.response?.data is Map ? (e.response?.data as Map)['code'] : null;
      final msg = code == 'ADDR001' ? '주소를 찾을 수 없습니다.' : '삭제에 실패했습니다.';
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다.')));
    }
  }
}

/// 주소 추가 바텀시트 — 성공 시 Navigator.pop(true)
class _AddAddressSheet extends ConsumerStatefulWidget {
  const _AddAddressSheet();

  @override
  ConsumerState<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<_AddAddressSheet> {
  final _aliasCtrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _addrCtrl = TextEditingController();
  final _detailCtrl = TextEditingController();
  bool _setDefault = false;
  bool _busy = false;

  @override
  void dispose() {
    _aliasCtrl.dispose();
    _zipCtrl.dispose();
    _addrCtrl.dispose();
    _detailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_addrCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('주소를 검색해 주세요.')));
      return;
    }
    setState(() => _busy = true);
    try {
      await ref.read(mypageDatasourceProvider).addAddress(
            alias: _aliasCtrl.text.trim(),
            zipcode: _zipCtrl.text.trim(),
            address: _addrCtrl.text.trim(),
            addressDetail: _detailCtrl.text.trim(),
            setDefault: _setDefault,
          );
      if (mounted) Navigator.pop(context, true);
    } on DioException catch (e) {
      final code =
          e.response?.data is Map ? (e.response?.data as Map)['code'] : null;
      final msg =
          code == 'ADDR002' ? '주소는 최대 10개까지 등록할 수 있습니다.' : '등록에 실패했습니다.';
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (_) {
      if (mounted) {
        setState(() => _busy = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('등록에 실패했습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('주소 추가',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            const Text('별칭', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            TextField(
              controller: _aliasCtrl,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: '예: 집, 회사 (미입력 시 "내 주소")',
                counterText: '',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.gray200)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.teal600)),
              ),
            ),
            const SizedBox(height: 12),
            AddressSearchField(
              postcodeController: _zipCtrl,
              addressController: _addrCtrl,
              detailController: _detailCtrl,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              activeThumbColor: AppColors.teal600,
              title: const Text('기본 배송지로 설정',
                  style: TextStyle(fontSize: 14)),
              value: _setDefault,
              onChanged: (v) => setState(() => _setDefault = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('저장'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.error_outline, size: 36, color: AppColors.gray400),
        const SizedBox(height: 10),
        const Center(
          child: Text('목록을 불러올 수 없습니다.',
              style: TextStyle(color: AppColors.gray400)),
        ),
        const SizedBox(height: 12),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.teal600,
                side: const BorderSide(color: AppColors.teal600)),
            child: const Text('다시 시도'),
          ),
        ),
      ],
    );
  }
}
