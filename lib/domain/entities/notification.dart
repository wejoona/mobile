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
    final referenceType = json['referenceType'] as String?;
    final referenceId = json['referenceId'] as String?;
    final isUnread = json['isUnread'] as bool?;

    return AppNotification(
      id: json['id'] as String,
      title: json['title'] as String? ?? 'Notification',
      body: json['body'] as String? ?? '',
      type: _parseNotificationType(
        json['type'] as String? ?? json['category'] as String?,
      ),
      isRead:
          json['isRead'] as bool? ??
          (isUnread != null ? !isUnread : json['readAt'] != null),
      actionUrl: json['actionUrl'] as String?,
      transactionId:
          json['transactionId'] as String? ??
          (referenceType == 'transaction' ? referenceId : null),
      data: data,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            json['sentAt'] as String? ??
            DateTime.now().toIso8601String(),
      ),
    );
  }

  static NotificationType _parseNotificationType(String? value) {
    if (value == null) return NotificationType.general;
    final normalized = value.replaceAll('-', '_').toLowerCase();
    switch (normalized) {
      case 'transfer_received':
      case 'transfer_sent':
      case 'transfer':
        return NotificationType.transfer;
      case 'deposit':
      case 'deposit_completed':
      case 'deposit_successful':
        return NotificationType.deposit;
      case 'withdrawal':
      case 'withdrawal_pending':
        return NotificationType.withdrawal;
      case 'security':
      case 'security_alert':
        return NotificationType.security;
      case 'kyc':
      case 'kyc_status':
        return NotificationType.kyc;
      case 'promotion':
      case 'marketing':
        return NotificationType.promotion;
      case 'low_balance':
        return NotificationType.lowBalance;
      case 'transaction_complete':
        return NotificationType.transactionComplete;
      case 'transaction_failed':
        return NotificationType.transactionFailed;
      default:
        return NotificationType.values.firstWhere(
          (type) => type.name.toLowerCase() == normalized,
          orElse: () => NotificationType.general,
        );
    }
  }
}
