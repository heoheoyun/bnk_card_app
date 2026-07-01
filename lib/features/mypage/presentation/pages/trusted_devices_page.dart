// 신뢰 기기 관리 — 기기 식별자 기반.
//  - 등록된 신뢰 기기 목록 조회 (최대 10개)
//  - 기기 이름 수정 (PATCH)
//  - 기기 삭제 (DELETE) — 최초 가입 기기는 삭제 불가
//
// 서버 계약:
//   GET    /api/users/me/trusted-devices
//   PATCH  /api/users/me/trusted-devices/{deviceTrustId}  { deviceName }
//   DELETE /api/users/me/trusted-devices/{deviceTrustId}

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../data/models/trusted_device_model.dart';
import '../providers/mypage_provider.dart';

const int _maxTrustedDevices = 10;

class TrustedDevicesPage extends ConsumerWidget {
  const TrustedDevicesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(trustedDevicesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BnkAppBar(title: '신뢰 기기 관리'),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.teal600,
          onRefresh: () async => ref.refresh(trustedDevicesProvider.future),
          child: async.when(
            loading: () =>
                const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            error: (_, __) => _ErrorView(
              onRetry: () => ref.invalidate(trustedDevicesProvider),
            ),
            data: (list) => _Body(items: list),
          ),
        ),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final List<TrustedDevice> items;
  const _Body({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      children: [
        // ── 안내 ──────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.teal50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.teal200),
          ),
          child: const Text(
            '등록된 기기에서는 별도 인증 없이 로그인할 수 있어요.\n'
            '새로운 기기에서 로그인하면 이메일/본인확인 인증이 필요합니다. (최대 10개)',
            style: TextStyle(fontSize: 12.5, color: AppColors.teal800, height: 1.5),
          ),
        ),
        const SizedBox(height: 16),

        // ── 카운트 ────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('등록된 기기',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray600)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: items.length >= _maxTrustedDevices
                    ? const Color(0xFFFFEBEE)
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${items.length} / $_maxTrustedDevices',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: items.length >= _maxTrustedDevices
                      ? Colors.red
                      : AppColors.gray600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.devices_other_outlined,
                      size: 36, color: AppColors.gray400),
                  SizedBox(height: 10),
                  Text('등록된 기기가 없습니다.',
                      style: TextStyle(color: AppColors.gray400)),
                ],
              ),
            ),
          )
        else
          ...items.map((e) => _DeviceCard(item: e)),
      ],
    );
  }
}

class _DeviceCard extends ConsumerWidget {
  final TrustedDevice item;
  const _DeviceCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.teal50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_platformIcon(item.platformCode),
                    size: 20, color: AppColors.teal600),
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
                            item.deviceName?.isNotEmpty == true
                                ? item.deviceName!
                                : '이름 없음',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (item.isInitial) ...[
                          const SizedBox(width: 6),
                          const _Badge(
                              text: '최초 기기',
                              color: AppColors.teal600,
                              bg: AppColors.teal50),
                        ],
                        if (!item.isActive) ...[
                          const SizedBox(width: 6),
                          const _Badge(
                              text: '비활성',
                              color: AppColors.gray600,
                              bg: AppColors.gray100),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _subtitleLine(),
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _metaLine(),
            style: const TextStyle(fontSize: 11.5, color: AppColors.gray400),
          ),
          if (!item.isInitial) ...[
            const Divider(height: 20, color: AppColors.gray100),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editName(context, ref),
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  style: TextButton.styleFrom(
                      foregroundColor: AppColors.teal600,
                      visualDensity: VisualDensity.compact),
                  label: const Text('이름 수정', style: TextStyle(fontSize: 13)),
                ),
                const SizedBox(width: 4),
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
        ],
      ),
    );
  }

  static IconData _platformIcon(String? p) => switch (p) {
        'IOS' => Icons.phone_iphone,
        'ANDROID' => Icons.phone_android,
        'WEB' => Icons.language,
        _ => Icons.devices_outlined,
      };

  String _subtitleLine() {
    final platform = _platformLabel(item.platformCode);
    final ip = item.lastIpMasked;
    final parts = <String>[
      if (platform.isNotEmpty) platform,
      if (ip != null && ip.isNotEmpty) '최근 IP $ip',
    ];
    return parts.isEmpty ? '-' : parts.join('  ·  ');
  }

  String _metaLine() {
    final via = _viaLabel(item.registeredVia);
    final created = _fmtDate(item.createdAt);
    final parts = <String>[
      if (via.isNotEmpty) via,
      if (created.isNotEmpty) '등록 $created',
      if (item.lastUsedAt != null) '최근 접속 ${_fmtDate(item.lastUsedAt)}',
    ];
    return parts.join('  ·  ');
  }

  static String _platformLabel(String? p) => switch (p) {
        'IOS' => 'iOS',
        'ANDROID' => 'Android',
        'WEB' => '웹 브라우저',
        _ => '',
      };

  static String _viaLabel(String? v) => switch (v) {
        'SIGNUP' => '회원가입 등록',
        'EMAIL_VERIFY' => '이메일 인증',
        'CI_VERIFY' => 'CI 인증',
        _ => v ?? '',
      };

  static String _fmtDate(DateTime? d) {
    if (d == null) return '';
    final l = d.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${l.year}.${two(l.month)}.${two(l.day)}';
  }

  // ── 이름 수정 ──────────────────────────────────────────────
  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final ctrl = TextEditingController(text: item.deviceName ?? '');
    final messenger = ScaffoldMessenger.of(context);

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('기기 이름 수정', style: TextStyle(fontSize: 16)),
        content: TextField(
          controller: ctrl,
          maxLength: 100,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '기기 이름 (예: 집 노트북)',
            counterText: '',
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.teal600, width: 1.2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal600,
                foregroundColor: Colors.white),
            child: const Text('저장'),
          ),
        ],
      ),
    );

    if (saved != true) return;
    final name = ctrl.text.trim();
    if (name.isEmpty) {
      messenger.showSnackBar(const SnackBar(content: Text('기기 이름을 입력해 주세요.')));
      return;
    }

    try {
      await ref
          .read(mypageDatasourceProvider)
          .updateTrustedDeviceName(item.deviceTrustId, name);
      ref.invalidate(trustedDevicesProvider);
      messenger.showSnackBar(const SnackBar(content: Text('기기 이름이 수정되었습니다.')));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('수정에 실패했습니다.')));
    }
  }

  // ── 삭제 ───────────────────────────────────────────────────
  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('기기 삭제', style: TextStyle(fontSize: 16)),
        content: const Text(
          '이 기기를 삭제하면 해당 기기에서 다시 로그인 시 인증이 필요합니다.\n정말 삭제하시겠습니까?',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: AppColors.gray600),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    try {
      await ref.read(mypageDatasourceProvider).deleteTrustedDevice(item.deviceTrustId);
      ref.invalidate(trustedDevicesProvider);
      messenger.showSnackBar(const SnackBar(content: Text('기기가 삭제되었습니다.')));
    } on DioException catch (e) {
      final code = e.response?.data is Map
          ? (e.response?.data as Map)['code']
          : null;
      final msg = switch (code) {
        'DEV004' => '최초 가입 기기는 삭제할 수 없습니다.',
        'DEV007' => '기기를 찾을 수 없습니다.',
        _ => '삭제에 실패했습니다.',
      };
      messenger.showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      messenger.showSnackBar(const SnackBar(content: Text('삭제에 실패했습니다.')));
    }
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color bg;
  const _Badge({required this.text, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(text,
            style: TextStyle(
                fontSize: 10, fontWeight: FontWeight.w600, color: color)),
      );
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
