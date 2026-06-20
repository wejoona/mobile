import 'package:usdc_wallet/domain/enums/index.dart';

/// Notification entity.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? severity;
  final String? action;
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
    this.severity,
    this.action,
    this.isRead = false,
    this.actionUrl,
    this.transactionId,
    this.data,
    required this.createdAt,
  });

  AppNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    String? severity,
    String? action,
    bool? isRead,
    String? actionUrl,
    String? transactionId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      action: action ?? this.action,
      isRead: isRead ?? this.isRead,
      actionUrl: actionUrl ?? this.actionUrl,
      transactionId: transactionId ?? this.transactionId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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
      severity: _normalizedString(json['severity']),
      action: json['action'] as String?,
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

  String? get navigationRoute {
    final safeActionUrl = _safeInAppPath(actionUrl);
    if (safeActionUrl != null) {
      return safeActionUrl;
    }

    final normalizedAction = action
        ?.trim()
        .replaceAll('-', '_')
        .replaceAll(' ', '_')
        .toLowerCase();
    switch (normalizedAction) {
      case 'open_transaction':
        final id = transactionId?.trim();
        return id == null || id.isEmpty ? '/transactions' : '/transactions/$id';
      case 'open_kyc':
        return '/kyc';
      case 'open_security':
        return '/settings/security';
      case 'open_wallet':
        return '/home';
      case 'none':
      case null:
        return _fallbackRouteForType();
      default:
        return _fallbackRouteForType();
    }
  }

  String? _fallbackRouteForType() {
    switch (type) {
      case NotificationType.transfer:
      case NotificationType.transactionComplete:
      case NotificationType.transactionFailed:
      case NotificationType.deposit:
      case NotificationType.withdrawal:
      case NotificationType.withdrawalPending:
      case NotificationType.largeTransaction:
      case NotificationType.externalWithdrawal:
        final id = transactionId?.trim();
        return id == null || id.isEmpty ? '/transactions' : '/transactions/$id';
      case NotificationType.kyc:
        return '/kyc';
      case NotificationType.security:
      case NotificationType.securityAlert:
      case NotificationType.newDeviceLogin:
      case NotificationType.unusualLocation:
      case NotificationType.suspiciousPattern:
      case NotificationType.failedAttempts:
      case NotificationType.accountChange:
      case NotificationType.rapidTransactions:
      case NotificationType.velocityLimit:
      case NotificationType.timeAnomaly:
        return '/settings/security';
      case NotificationType.lowBalance:
      case NotificationType.balanceThreshold:
      case NotificationType.addressWhitelisted:
      case NotificationType.priceAlert:
      case NotificationType.weeklySpendingSummary:
      case NotificationType.newRecipient:
      case NotificationType.roundAmount:
      case NotificationType.cumulativeDaily:
      case NotificationType.promotion:
      case NotificationType.general:
        return null;
    }
  }
}

String? _safeInAppPath(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty || !value.startsWith('/')) {
    return null;
  }
  if (value.startsWith('//') || value.contains('://')) {
    return null;
  }
  const exactRoutes = {
    '/home',
    '/transactions',
    '/settings/security',
    '/settings/devices',
    '/settings/kyc',
    '/kyc',
    '/deposit',
    '/referrals',
    '/notifications',
  };
  if (exactRoutes.contains(value)) {
    return value;
  }
  const allowedPrefixes = {
    '/transactions/',
    '/payment-links/detail/',
    '/payment-links/created/',
  };
  return allowedPrefixes.any(value.startsWith) ? value : null;
}

NotificationType _notificationTypeFromJson(Map<String, dynamic> json) {
  final normalized =
      (json['presentationType'] ?? json['type'] ?? json['category'] ?? '')
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
    case 'transaction_complete':
    case 'transactioncomplete':
    case 'transfer':
    case 'transfer_received':
    case 'transfer_sent':
      if (normalized == 'transaction_complete' ||
          normalized == 'transactioncomplete') {
        return NotificationType.transactionComplete;
      }
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
    case 'transaction_failed':
      return NotificationType.transactionFailed;
    default:
      return NotificationType.general;
  }
}

String? _normalizedString(Object? value) {
  final text = value?.toString().trim().toLowerCase();
  return text == null || text.isEmpty ? null : text;
}
