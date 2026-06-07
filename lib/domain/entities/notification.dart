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
      type: _notificationTypeFromJson(json),
      isRead:
          json['isRead'] as bool? ??
          (isUnread != null ? !isUnread : json['readAt'] != null),
      actionUrl: json['actionUrl'] as String?,
      transactionId:
          json['transactionId'] as String? ??
          (referenceType == 'transaction' ? referenceId : null) ??
          data?['transactionId'] as String?,
      data: data,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ??
            json['sentAt'] as String? ??
            DateTime.now().toIso8601String(),
      ),
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
    case 'transfer_received':
    case 'transfer_sent':
      return NotificationType.transfer;
    case 'deposit':
    case 'deposit_completed':
    case 'deposit_successful':
      return NotificationType.deposit;
    case 'withdrawal':
    case 'withdrawal_pending':
      return NotificationType.withdrawal;
    case 'kyc':
    case 'kyc_status':
    case 'identity':
      return NotificationType.kyc;
    case 'security':
    case 'security_alert':
    case 'risk':
      return NotificationType.security;
    case 'marketing':
    case 'promotion':
    case 'referral':
      return NotificationType.promotion;
    case 'low_balance':
      return NotificationType.lowBalance;
    case 'transaction_complete':
      return NotificationType.transactionComplete;
    case 'transaction_failed':
      return NotificationType.transactionFailed;
    default:
      return NotificationType.general;
  }
}
