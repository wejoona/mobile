import 'package:usdc_wallet/domain/enums/index.dart';

/// Notification entity.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final bool isRead;
  final String? actionUrl;
  final String? transactionId;
  final Map<String, dynamic>? data;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    this.actionUrl,
    this.transactionId,
    this.data,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : null;

    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: _notificationTypeFromJson(json),
      isRead: json['isRead'] as bool? ?? json['readAt'] != null,
      actionUrl: json['actionUrl'] as String?,
      transactionId:
          json['transactionId'] as String? ?? data?['transactionId'] as String?,
      data: data,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

NotificationType _notificationTypeFromJson(Map<String, dynamic> json) {
  final normalized = (json['type'] ?? json['category'] ?? '')
      .toString()
      .trim()
      .replaceAll('-', '_')
      .replaceAll(' ', '_')
      .toLowerCase();

  for (final type in NotificationType.values) {
    if (type.name.toLowerCase() == normalized) return type;
  }

  switch (normalized) {
    case 'transaction':
    case 'transfer':
      return NotificationType.transfer;
    case 'deposit':
      return NotificationType.deposit;
    case 'withdrawal':
      return NotificationType.withdrawal;
    case 'kyc':
    case 'identity':
      return NotificationType.kyc;
    case 'security':
    case 'risk':
      return NotificationType.security;
    case 'marketing':
    case 'promotion':
    case 'referral':
      return NotificationType.promotion;
    default:
      return NotificationType.general;
  }
}
