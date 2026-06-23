import 'package:dio/dio.dart';
import '../../../../core/constants/api_paths.dart';
import '../../../../core/network/dio_client.dart';
import '../models/notification_model.dart';

/// 사용자 알림 API 클라이언트.
/// 백엔드 NotificationController(`/api/notifications`)와 매핑된다.
class NotificationRemoteDatasource {
  final Dio _dio = DioClient.instance;

  /// GET /api/notifications
  /// 응답: { data: { unreadCount: int, notifications: [ ... ] } }
  Future<({int unreadCount, List<NotificationModel> items})>
      getMyNotifications() async {
    final res = await _dio.get(ApiPaths.notifications);
    final data = res.data['data'] as Map<String, dynamic>? ?? const {};
    final rawList = (data['notifications'] as List?) ?? const [];
    final items = rawList
        .map((e) => NotificationModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return (
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
      items: items,
    );
  }

  /// GET /api/notifications/unread-count  (헤더 뱃지 폴링용)
  Future<int> getUnreadCount() async {
    final res = await _dio.get(ApiPaths.notificationsUnreadCount);
    return (res.data['data'] as num?)?.toInt() ?? 0;
  }

  /// PATCH /api/notifications/{id}/read
  Future<void> markAsRead(int notificationId) =>
      _dio.patch(ApiPaths.notificationRead(notificationId));

  /// PATCH /api/notifications/read-all
  Future<void> markAllAsRead() => _dio.patch(ApiPaths.notificationsReadAll);
}
