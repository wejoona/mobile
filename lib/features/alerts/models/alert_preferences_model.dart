/// Alert Preferences Model
/// Data model for user alert preferences
library;

import 'package:usdc_wallet/features/alerts/models/alert_model.dart';

/// Digest frequency options
enum DigestFrequency {
  realtime,
  hourly,
  daily,
  weekly,
}

extension DigestFrequencyExtension on DigestFrequency {
  String get displayName {
    switch (this) {
      case DigestFrequency.realtime:
        return 'Real-time';
      case DigestFrequency.hourly:
        return 'Hourly';
      case DigestFrequency.daily:
        return 'Daily';
      case DigestFrequency.weekly:
        return 'Weekly';
    }
  }

  String get description {
    switch (this) {
      case DigestFrequency.realtime:
        return 'Get notified immediately';
      case DigestFrequency.hourly:
        return 'Hourly summary';
      case DigestFrequency.daily:
        return 'Daily digest at 9 AM';
      case DigestFrequency.weekly:
        return 'Weekly summary on Mondays';
    }
  }
}

/// User alert preferences
class AlertPreferences {
  final String userId;
  // Notification channels
  final bool emailAlerts;
  final bool pushAlerts;
  final bool smsAlerts;
  // Thresholds
  final double largeTransactionThreshold;
  final double balanceLowThreshold;
  final double? balanceHighThreshold;
  final double? dailyLimitThreshold;
  // Alert type subscriptions
  final List<AlertType> alertTypes;
  // Quiet hours
  final bool quietHoursEnabled;
  final String? quietHoursStart;
  final String? quietHoursEnd;
  final String timezone;
  // Settings
  final bool instantCriticalAlerts;
  final DigestFrequency digestFrequency;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlertPreferences({
    required this.userId,
    required this.emailAlerts,
    required this.pushAlerts,
    required this.smsAlerts,
    required this.largeTransactionThreshold,
    required this.balanceLowThreshold,
    this.balanceHighThreshold,
    this.dailyLimitThreshold,
    required this.alertTypes,
    required this.quietHoursEnabled,
    this.quietHoursStart,
    this.quietHoursEnd,
    required this.timezone,
    required this.instantCriticalAlerts,
    required this.digestFrequency,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AlertPreferences.fromJson(Map<String, dynamic> json) {
    return AlertPreferences(
      userId: json['userId'] as String,
      emailAlerts: json['emailAlerts'] as bool? ?? true,
      pushAlerts: json['pushAlerts'] as bool? ?? true,
      smsAlerts: json['smsAlerts'] as bool? ?? false,
      largeTransactionThreshold:
          (json['largeTransactionThreshold'] as num?)?.toDouble() ?? 1000,
      balanceLowThreshold:
          (json['balanceLowThreshold'] as num?)?.toDouble() ?? 10,
      balanceHighThreshold:
          (json['balanceHighThreshold'] as num?)?.toDouble(),
      dailyLimitThreshold:
          (json['dailyLimitThreshold'] as num?)?.toDouble(),
      alertTypes: (json['alertTypes'] as List?)
              ?.map((t) => AlertTypeExtension.fromValue(t as String))
              .toList() ??
          [],
      quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
      quietHoursStart: json['quietHoursStart'] as String?,
      quietHoursEnd: json['quietHoursEnd'] as String?,
      timezone: json['timezone'] as String? ?? 'UTC',
      instantCriticalAlerts: json['instantCriticalAlerts'] as bool? ?? true,
      digestFrequency: DigestFrequency.values.firstWhere(
        (d) => d.name == json['digestFrequency'],
        orElse: () => DigestFrequency.realtime,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'emailAlerts': emailAlerts,
      'pushAlerts': pushAlerts,
      'smsAlerts': smsAlerts,
      'largeTransactionThreshold': largeTransactionThreshold,
      'balanceLowThreshold': balanceLowThreshold,
      'balanceHighThreshold': balanceHighThreshold,
      'dailyLimitThreshold': dailyLimitThreshold,
      'alertTypes': alertTypes.map((t) => t.value).toList(),
      'quietHoursEnabled': quietHoursEnabled,
      'quietHoursStart': quietHoursStart,
      'quietHoursEnd': quietHoursEnd,
      'timezone': timezone,
      'instantCriticalAlerts': instantCriticalAlerts,
      'digestFrequency': digestFrequency.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AlertPreferences copyWith({
    String? userId,
    bool? emailAlerts,
    bool? pushAlerts,
    bool? smsAlerts,
    double? largeTransactionThreshold,
    double? balanceLowThreshold,
    double? balanceHighThreshold,
    double? dailyLimitThreshold,
    List<AlertType>? alertTypes,
    bool? quietHoursEnabled,
    String? quietHoursStart,
    String? quietHoursEnd,
    String? timezone,
    bool? instantCriticalAlerts,
    DigestFrequency? digestFrequency,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AlertPreferences(
      userId: userId ?? this.userId,
      emailAlerts: emailAlerts ?? this.emailAlerts,
      pushAlerts: pushAlerts ?? this.pushAlerts,
      smsAlerts: smsAlerts ?? this.smsAlerts,
      largeTransactionThreshold:
          largeTransactionThreshold ?? this.largeTransactionThreshold,
      balanceLowThreshold: balanceLowThreshold ?? this.balanceLowThreshold,
      balanceHighThreshold: balanceHighThreshold ?? this.balanceHighThreshold,
      dailyLimitThreshold: dailyLimitThreshold ?? this.dailyLimitThreshold,
      alertTypes: alertTypes ?? this.alertTypes,
      quietHoursEnabled: quietHoursEnabled ?? this.quietHoursEnabled,
      quietHoursStart: quietHoursStart ?? this.quietHoursStart,
      quietHoursEnd: quietHoursEnd ?? this.quietHoursEnd,
      timezone: timezone ?? this.timezone,
      instantCriticalAlerts:
          instantCriticalAlerts ?? this.instantCriticalAlerts,
      digestFrequency: digestFrequency ?? this.digestFrequency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if a specific alert type is enabled
  bool isAlertTypeEnabled(AlertType type) {
    return alertTypes.contains(type);
  }

  /// Check if any notification channel is enabled
  bool get hasAnyChannelEnabled => emailAlerts || pushAlerts || smsAlerts;

  /// Default preferences for new users
  static AlertPreferences defaultPreferences(String userId) {
    return AlertPreferences(
      userId: userId,
      emailAlerts: true,
      pushAlerts: true,
      smsAlerts: false,
      largeTransactionThreshold: 1000,
      balanceLowThreshold: 10,
      balanceHighThreshold: null,
      dailyLimitThreshold: 5000,
      alertTypes: [
        AlertType.largeTransaction,
        AlertType.unusualLocation,
        AlertType.rapidTransactions,
        AlertType.newRecipient,
        AlertType.failedAttempts,
        AlertType.loginNewDevice,
        AlertType.balanceThreshold,
        AlertType.externalWithdrawal,
      ],
      quietHoursEnabled: false,
      quietHoursStart: '22:00',
      quietHoursEnd: '07:00',
      timezone: 'UTC',
      instantCriticalAlerts: true,
      digestFrequency: DigestFrequency.realtime,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

/// Alert type info for display
class AlertTypeInfo {
  final AlertType type;
  final String name;
  final String description;
  final bool defaultEnabled;

  const AlertTypeInfo({
    required this.type,
    required this.name,
    required this.description,
    required this.defaultEnabled,
  });

  factory AlertTypeInfo.fromJson(Map<String, dynamic> json) {
    return AlertTypeInfo(
      type: AlertTypeExtension.fromValue(json['type'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      defaultEnabled: json['defaultEnabled'] as bool,
    );
  }
}
