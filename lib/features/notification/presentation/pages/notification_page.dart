import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/bnk_app_bar.dart';
import '../../data/models/notification_model.dart';
import '../providers/notification_provider.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(notificationListProvider);
    final unread = async.valueOrNull?.unreadCount ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BnkAppBar(
        title: '알림',
        backPath: '/',
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () => _markAll(context, ref),
              child: const Text('전체 읽음',
                  style: TextStyle(color: Colors.white, fontSize: 13)),
            ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.teal600,
        onRefresh: () async {
          ref.invalidate(notificationListProvider);
          await ref.read(notificationListProvider.future);
          await ref.read(unreadCountProvider.notifier).refresh();
        },
        child: async.when(
          loading: () =>
          const Center(child: CircularProgressIndicator(color: AppColors.teal600)),
          error: (_, __) => _ErrorView(
            onRetry: () => ref.invalidate(notificationListProvider),
          ),
          data: (state) {
            if (state.items.isEmpty) return const _EmptyView();
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: state.items.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1, indent: 64, color: AppColors.gray100),
              itemBuilder: (_, i) => _NotificationTile(
                item: state.items[i],
                onTap: () => _open(context, ref, state.items[i]),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _open(
      BuildContext context, WidgetRef ref, NotificationModel n) async {
    final ds = ref.read(notificationDatasourceProvider);
    if (!n.isRead) {
      try {
        await ds.markAsRead(n.notificationId);
        ref.invalidate(notificationListProvider);
        await ref.read(unreadCountProvider.notifier).refresh();
      } catch (_) {/* 읽음 처리 실패해도 이동은 진행 */}
    }
    // 딥링크 이동 — 현재 앱 라우트와 매핑되는 경로만 처리(나머지는 목록 유지).
    final link = n.linkUrl;
    if (context.mounted && link != null && link.startsWith('/cards/')) {
      context.push(link);
    }
  }

  Future<void> _markAll(BuildContext context, WidgetRef ref) async {
    final ds = ref.read(notificationDatasourceProvider);
    try {
      await ds.markAllAsRead();
      ref.invalidate(notificationListProvider);
      await ref.read(unreadCountProvider.notifier).refresh();
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('처리에 실패했습니다. 잠시 후 다시 시도해 주세요.')),
        );
      }
    }
  }
}

// ── 알림 한 줄 ──────────────────────────────────────────────────────
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});

  final NotificationModel item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final meta = item.meta;
    return InkWell(
      onTap: onTap,
      child: Container(
        color: item.isRead ? Colors.white : meta.color.withValues(alpha: 0.05),
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(meta.icon, size: 19, color: meta.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(meta.label,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: meta.color)),
                      const SizedBox(width: 6),
                      Text(_timeAgo(item.createdAt),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.gray400)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                        item.isRead ? FontWeight.w500 : FontWeight.w700,
                        color: AppColors.gray800,
                      )),
                  if (item.message.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 12.5,
                            height: 1.4,
                            color: AppColors.gray600)),
                  ],
                ],
              ),
            ),
            if (!item.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Color(0xFFE53935), shape: BoxShape.circle),
              ),
          ],
        ),
      ),
    );
  }

  static String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    final d = dt;
    return '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';
  }
}

// ── 빈 화면 ─────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.notifications_none,
            size: 56, color: AppColors.gray400.withValues(alpha: 0.6)),
        const SizedBox(height: 12),
        const Center(
          child: Text('새 알림이 없습니다.',
              style: TextStyle(fontSize: 14, color: AppColors.gray600)),
        ),
      ],
    );
  }
}

// ── 오류 화면 ───────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        const Center(
          child: Text('알림을 불러오지 못했습니다.',
              style: TextStyle(fontSize: 14, color: AppColors.gray600)),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ),
      ],
    );
  }
}