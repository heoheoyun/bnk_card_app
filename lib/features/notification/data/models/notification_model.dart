import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 서버 NotificationResponse 와 1:1 대응하는 앱 모델.
///
/// 서버 JSON 예:
/// ```
/// {
///   "notificationId": 12,
///   "notificationCategory": "CARD_UPDATED",
///   "channel": "INAPP",
///   "title": "카드 정보가 변경되었습니다",
///   "message": "'BNK 톡톡카드' 혜택이 업데이트되었습니다.",
///   "linkUrl": "/cards/45",
///   "readYn": "N",
///   "createdAt": "2026-06-23T10:15:30"
/// }
/// ```
class NotificationModel {
  final int notificationId;
  final String category; // TERMS_CHANGED / CARD_UPDATED / EVENT / NOTICE / SYSTEM
  final String channel; // INAPP / PUSH / EMAIL / SMS
  final String title;
  final String message;
  final String? linkUrl;
  final bool isRead;
  final DateTime? createdAt;

  const NotificationModel({
    required this.notificationId,
    required this.category,
    required this.channel,
    required this.title,
    required this.message,
    this.linkUrl,
    required this.isRead,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> j) {
    final created = j['createdAt'];
    return NotificationModel(
      notificationId: (j['notificationId'] as num).toInt(),
      category: j['notificationCategory'] as String? ?? 'SYSTEM',
      channel: j['channel'] as String? ?? 'INAPP',
      title: j['title'] as String? ?? '',
      message: j['message'] as String? ?? '',
      linkUrl: j['linkUrl'] as String?,
      // 서버는 read_yn 을 'Y' / 'N' CHAR(1) 로 내려준다.
      isRead: (j['readYn'] as String? ?? 'N') == 'Y',
      createdAt: created is String ? DateTime.tryParse(created) : null,
    );
  }

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        notificationId: notificationId,
        category: category,
        channel: channel,
        title: title,
        message: message,
        linkUrl: linkUrl,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  NotificationCategoryMeta get meta =>
      NotificationCategoryMeta.of(category);
}

/// 카테고리별 표현(아이콘·라벨·색). 관리자 웹(notification.js)의 CAT_ICON 매핑과 일치.
class NotificationCategoryMeta {
  final IconData icon;
  final String label;
  final Color color;

  const NotificationCategoryMeta(this.icon, this.label, this.color);

  static NotificationCategoryMeta of(String category) {
    switch (category) {
      case 'TERMS_CHANGED':
        return const NotificationCategoryMeta(
            Icons.description_outlined, '약관', AppColors.teal600);
      case 'CARD_UPDATED':
        return const NotificationCategoryMeta(
            Icons.credit_card, '카드', Color(0xFF3B82F6));
      case 'EVENT':
        return const NotificationCategoryMeta(
            Icons.card_giftcard, '이벤트', Color(0xFFEC4899));
      case 'NOTICE':
        return const NotificationCategoryMeta(
            Icons.campaign_outlined, '공지', Color(0xFFF59E0B));
      case 'SYSTEM':
      default:
        return const NotificationCategoryMeta(
            Icons.settings_outlined, '시스템', AppColors.gray600);
    }
  }
}
