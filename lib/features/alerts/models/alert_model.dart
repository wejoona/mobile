/// Alert Models
/// Data models for transaction alerts system
library;

import 'package:flutter/material.dart';

/// Alert severity levels
enum AlertSeverity {
  info,
  warning,
  critical,
}

extension AlertSeverityExtension on AlertSeverity {
  String get displayName {
    switch (this) {
      case AlertSeverity.info:
        return 'Info';
      case AlertSeverity.warning:
        return 'Warning';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  Color get color {
    switch (this) {
      case AlertSeverity.info:
        return const Color(0xFF2196F3);
      case AlertSeverity.warning:
        return const Color(0xFFFF9800);
      case AlertSeverity.critical:
        return const Color(0xFFF44336);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AlertSeverity.info:
        return const Color(0xFF2196F3).withValues(alpha: 0.15);
      case AlertSeverity.warning:
        return const Color(0xFFFF9800).withValues(alpha: 0.15);
      case AlertSeverity.critical:
        return const Color(0xFFF44336).withValues(alpha: 0.15);
    }
  }
}

/// Alert types
enum AlertType {
  largeTransaction,
  unusualLocation,
  rapidTransactions,
  newRecipient,
  suspiciousPattern,
  failedAttempts,
  accountChange,
  loginNewDevice,
  balanceThreshold,
  externalWithdrawal,
  timeAnomaly,
  roundAmount,
  cumulativeDaily,
  velocityLimit,
}

extension AlertTypeExtension on AlertType {
  String get value {
    switch (this) {
      case AlertType.largeTransaction:
        return 'large_transaction';
      case AlertType.unusualLocation:
        return 'unusual_location';
      case AlertType.rapidTransactions:
        return 'rapid_transactions';
      case AlertType.newRecipient:
        return 'new_recipient';
      case AlertType.suspiciousPattern:
        return 'suspicious_pattern';
      case AlertType.failedAttempts:
        return 'failed_attempts';
      case AlertType.accountChange:
        return 'account_change';
      case AlertType.loginNewDevice:
        return 'login_new_device';
      case AlertType.balanceThreshold:
        return 'balance_threshold';
      case AlertType.externalWithdrawal:
        return 'external_withdrawal';
      case AlertType.timeAnomaly:
        return 'time_anomaly';
      case AlertType.roundAmount:
        return 'round_amount';
      case AlertType.cumulativeDaily:
        return 'cumulative_daily';
      case AlertType.velocityLimit:
        return 'velocity_limit';
    }
  }

  static AlertType fromValue(String value) {
    switch (value) {
      case 'large_transaction':
        return AlertType.largeTransaction;
      case 'unusual_location':
        return AlertType.unusualLocation;
      case 'rapid_transactions':
        return AlertType.rapidTransactions;
      case 'new_recipient':
        return AlertType.newRecipient;
      case 'suspicious_pattern':
        return AlertType.suspiciousPattern;
      case 'failed_attempts':
        return AlertType.failedAttempts;
      case 'account_change':
        return AlertType.accountChange;
      case 'login_new_device':
        return AlertType.loginNewDevice;
      case 'balance_threshold':
        return AlertType.balanceThreshold;
      case 'external_withdrawal':
        return AlertType.externalWithdrawal;
      case 'time_anomaly':
        return AlertType.timeAnomaly;
      case 'round_amount':
        return AlertType.roundAmount;
      case 'cumulative_daily':
        return AlertType.cumulativeDaily;
      case 'velocity_limit':
        return AlertType.velocityLimit;
      default:
        return AlertType.suspiciousPattern;
    }
  }

  String get displayName {
    switch (this) {
      case AlertType.largeTransaction:
        return 'Large Transaction';
      case AlertType.unusualLocation:
        return 'Unusual Location';
      case AlertType.rapidTransactions:
        return 'Rapid Transactions';
      case AlertType.newRecipient:
        return 'New Recipient';
      case AlertType.suspiciousPattern:
        return 'Suspicious Pattern';
      case AlertType.failedAttempts:
        return 'Failed Attempts';
      case AlertType.accountChange:
        return 'Account Change';
      case AlertType.loginNewDevice:
        return 'New Device Login';
      case AlertType.balanceThreshold:
        return 'Balance Alert';
      case AlertType.externalWithdrawal:
        return 'External Withdrawal';
      case AlertType.timeAnomaly:
        return 'Unusual Time';
      case AlertType.roundAmount:
        return 'Round Amount';
      case AlertType.cumulativeDaily:
        return 'Daily Limit';
      case AlertType.velocityLimit:
        return 'Velocity Limit';
    }
  }

  String get description {
    switch (this) {
      case AlertType.largeTransaction:
        return 'Transaction amount exceeds your threshold';
      case AlertType.unusualLocation:
        return 'Transaction from different country or IP';
      case AlertType.rapidTransactions:
        return 'Multiple transactions in short time';
      case AlertType.newRecipient:
        return 'First transaction to this address';
      case AlertType.suspiciousPattern:
        return 'Unusual transaction pattern detected';
      case AlertType.failedAttempts:
        return 'Multiple failed transaction attempts';
      case AlertType.accountChange:
        return 'Profile or security settings changed';
      case AlertType.loginNewDevice:
        return 'Login from new device detected';
      case AlertType.balanceThreshold:
        return 'Balance crossed threshold';
      case AlertType.externalWithdrawal:
        return 'Funds sent to external address';
      case AlertType.timeAnomaly:
        return 'Transaction at unusual hour';
      case AlertType.roundAmount:
        return 'Suspiciously round transaction amount';
      case AlertType.cumulativeDaily:
        return 'Daily transaction volume exceeded';
      case AlertType.velocityLimit:
        return 'Transaction rate limit exceeded';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertType.largeTransaction:
        return Icons.attach_money;
      case AlertType.unusualLocation:
        return Icons.location_off;
      case AlertType.rapidTransactions:
        return Icons.speed;
      case AlertType.newRecipient:
        return Icons.person_add;
      case AlertType.suspiciousPattern:
        return Icons.warning;
      case AlertType.failedAttempts:
        return Icons.error_outline;
      case AlertType.accountChange:
        return Icons.settings;
      case AlertType.loginNewDevice:
        return Icons.phone_android;
      case AlertType.balanceThreshold:
        return Icons.account_balance_wallet;
      case AlertType.externalWithdrawal:
        return Icons.call_made;
      case AlertType.timeAnomaly:
        return Icons.schedule;
      case AlertType.roundAmount:
        return Icons.monetization_on;
      case AlertType.cumulativeDaily:
        return Icons.trending_up;
      case AlertType.velocityLimit:
        return Icons.flash_on;
    }
  }

  Color get color {
    switch (this) {
      case AlertType.largeTransaction:
        return const Color(0xFFFF9800);
      case AlertType.unusualLocation:
        return const Color(0xFFF44336);
      case AlertType.rapidTransactions:
        return const Color(0xFFFF9800);
      case AlertType.newRecipient:
        return const Color(0xFF2196F3);
      case AlertType.suspiciousPattern:
        return const Color(0xFFF44336);
      case AlertType.failedAttempts:
        return const Color(0xFFFF9800);
      case AlertType.accountChange:
        return const Color(0xFF2196F3);
      case AlertType.loginNewDevice:
        return const Color(0xFF9C27B0);
      case AlertType.balanceThreshold:
        return const Color(0xFF4CAF50);
      case AlertType.externalWithdrawal:
        return const Color(0xFFFF9800);
      case AlertType.timeAnomaly:
        return const Color(0xFF607D8B);
      case AlertType.roundAmount:
        return const Color(0xFFFF9800);
      case AlertType.cumulativeDaily:
        return const Color(0xFFFF9800);
      case AlertType.velocityLimit:
        return const Color(0xFFFF9800);
    }
  }
}

/// Alert action types
enum AlertAction {
  blockRecipient,
  verifyIdentity,
  reportSuspicious,
  contactSupport,
  dismiss,
  require2fa,
  freezeAccount,
}

extension AlertActionExtension on AlertAction {
  String get value {
    switch (this) {
      case AlertAction.blockRecipient:
        return 'block_recipient';
      case AlertAction.verifyIdentity:
        return 'verify_identity';
      case AlertAction.reportSuspicious:
        return 'report_suspicious';
      case AlertAction.contactSupport:
        return 'contact_support';
      case AlertAction.dismiss:
        return 'dismiss';
      case AlertAction.require2fa:
        return 'require_2fa';
      case AlertAction.freezeAccount:
        return 'freeze_account';
    }
  }

  String get displayName {
    switch (this) {
      case AlertAction.blockRecipient:
        return 'Block this recipient';
      case AlertAction.verifyIdentity:
        return 'Verify this was me';
      case AlertAction.reportSuspicious:
        return 'Report suspicious activity';
      case AlertAction.contactSupport:
        return 'Contact support';
      case AlertAction.dismiss:
        return 'Dismiss';
      case AlertAction.require2fa:
        return 'Require 2FA';
      case AlertAction.freezeAccount:
        return 'Freeze account';
    }
  }

  IconData get icon {
    switch (this) {
      case AlertAction.blockRecipient:
        return Icons.block;
      case AlertAction.verifyIdentity:
        return Icons.verified_user;
      case AlertAction.reportSuspicious:
        return Icons.report;
      case AlertAction.contactSupport:
        return Icons.support_agent;
      case AlertAction.dismiss:
        return Icons.close;
      case AlertAction.require2fa:
        return Icons.security;
      case AlertAction.freezeAccount:
        return Icons.lock;
    }
  }
}

/// Transaction alert model
class TransactionAlert {
  final String alertId;
  final String userId;
  final String? transactionId;
  final AlertType alertType;
  final AlertSeverity severity;
  final String title;
  final String message;
  final Map<String, dynamic> metadata;
  final bool isRead;
  final bool isActionRequired;
  final AlertAction? actionTaken;
  final DateTime? actionTakenAt;
  final DateTime? expiresAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionAlert({
    required this.alertId,
    required this.userId,
    this.transactionId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    required this.metadata,
    required this.isRead,
    required this.isActionRequired,
    this.actionTaken,
    this.actionTakenAt,
    this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionAlert.fromJson(Map<String, dynamic> json) {
    return TransactionAlert(
      alertId: json['alertId'] as String,
      userId: json['userId'] as String,
      transactionId: json['transactionId'] as String?,
      alertType: AlertTypeExtension.fromValue(json['alertType'] as String),
      severity: AlertSeverity.values.firstWhere(
        (s) => s.name == json['severity'],
        orElse: () => AlertSeverity.info,
      ),
      title: json['title'] as String,
      message: json['message'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      isRead: json['isRead'] as bool? ?? false,
      isActionRequired: json['isActionRequired'] as bool? ?? false,
      actionTaken: json['actionTaken'] != null
          ? AlertAction.values.firstWhere(
              (a) => a.value == json['actionTaken'],
              orElse: () => AlertAction.dismiss,
            )
          : null,
      actionTakenAt: json['actionTakenAt'] != null
          ? DateTime.parse(json['actionTakenAt'] as String)
          : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alertId': alertId,
      'userId': userId,
      'transactionId': transactionId,
      'alertType': alertType.value,
      'severity': severity.name,
      'title': title,
      'message': message,
      'metadata': metadata,
      'isRead': isRead,
      'isActionRequired': isActionRequired,
      'actionTaken': actionTaken?.value,
      'actionTakenAt': actionTakenAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TransactionAlert copyWith({
    String? alertId,
    String? userId,
    String? transactionId,
    AlertType? alertType,
    AlertSeverity? severity,
    String? title,
    String? message,
    Map<String, dynamic>? metadata,
    bool? isRead,
    bool? isActionRequired,
    AlertAction? actionTaken,
    DateTime? actionTakenAt,
    DateTime? expiresAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionAlert(
      alertId: alertId ?? this.alertId,
      userId: userId ?? this.userId,
      transactionId: transactionId ?? this.transactionId,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      isActionRequired: isActionRequired ?? this.isActionRequired,
      actionTaken: actionTaken ?? this.actionTaken,
      actionTakenAt: actionTakenAt ?? this.actionTakenAt,
      expiresAt: expiresAt ?? this.expiresAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get the amount from metadata if available
  double? get amount => metadata['amount'] as double?;

  /// Get the currency from metadata if available
  String? get currency => metadata['currency'] as String?;

  /// Check if the alert is expired
  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  /// Get available actions for this alert
  List<AlertAction> get availableActions {
    final actions = <AlertAction>[];

    if (!isRead) {
      actions.add(AlertAction.dismiss);
    }

    switch (alertType) {
      case AlertType.newRecipient:
      case AlertType.externalWithdrawal:
        actions.add(AlertAction.blockRecipient);
        actions.add(AlertAction.verifyIdentity);
        break;
      case AlertType.suspiciousPattern:
      case AlertType.unusualLocation:
        actions.add(AlertAction.verifyIdentity);
        actions.add(AlertAction.reportSuspicious);
        actions.add(AlertAction.freezeAccount);
        break;
      case AlertType.loginNewDevice:
        actions.add(AlertAction.verifyIdentity);
        actions.add(AlertAction.require2fa);
        break;
      case AlertType.failedAttempts:
        actions.add(AlertAction.require2fa);
        actions.add(AlertAction.reportSuspicious);
        break;
      default:
        actions.add(AlertAction.verifyIdentity);
        break;
    }

    actions.add(AlertAction.contactSupport);

    return actions;
  }
}

/// Paginated alerts response
class PaginatedAlerts {
  final List<TransactionAlert> alerts;
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;

  const PaginatedAlerts({
    required this.alerts,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  factory PaginatedAlerts.fromJson(Map<String, dynamic> json) {
    return PaginatedAlerts(
      alerts: (json['alerts'] as List)
          .map((a) => TransactionAlert.fromJson(a as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
      hasNext: json['hasNext'] as bool,
      hasPrevious: json['hasPrevious'] as bool,
    );
  }
}

/// Alert statistics
class AlertStatistics {
  final int total;
  final int unread;
  final int critical;
  final int actionRequired;
  final Map<String, int> byType;
  final Map<String, int> bySeverity;

  const AlertStatistics({
    required this.total,
    required this.unread,
    required this.critical,
    required this.actionRequired,
    required this.byType,
    required this.bySeverity,
  });

  factory AlertStatistics.fromJson(Map<String, dynamic> json) {
    return AlertStatistics(
      total: json['total'] as int,
      unread: json['unread'] as int,
      critical: json['critical'] as int,
      actionRequired: json['actionRequired'] as int,
      byType: Map<String, int>.from(json['byType'] as Map? ?? {}),
      bySeverity: Map<String, int>.from(json['bySeverity'] as Map? ?? {}),
    );
  }
}
