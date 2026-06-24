import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/notification_provider.dart';

/// 알림 벨 + 미읽음 뱃지. 탭 시 알림센터(`/notifications`)로 이동.
///
/// 헤더(teal 배경)에서는 [iconColor] = Colors.white,
/// 라이트 배경 AppBar 에서는 기본 흰색/지정색을 넘겨 재사용한다.
class NotificationBell extends ConsumerWidget {
  const NotificationBell({
    super.key,
    this.iconColor = Colors.white,
    this.iconSize = 22,
    this.filled = true,
  });

  /// true 면 헤더용 반투명 원형 배경, false 면 일반 AppBar 아이콘.
  final bool filled;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);

    final button = IconButton(
      onPressed: () => context.push('/notifications'),
      tooltip: '알림',
      icon: Icon(Icons.notifications_outlined,
          color: iconColor, size: iconSize),
      style: filled
          ? IconButton.styleFrom(
              backgroundColor: Colors.white24,
              padding: const EdgeInsets.all(6),
            )
          : null,
    );

    if (unread <= 0) return button;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        button,
        Positioned(
          right: filled ? 2 : 6,
          top: filled ? 2 : 8,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(9),
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Center(
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    height: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
