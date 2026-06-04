/// UserNotificationPreferences entity - mirrors backend NotificationPreferences domain entity
/// This is the backend-synced version that persists user notification settings
class UserNotificationPreferences {
  final String id;
  final String userId;
  // Push notification settings
  final bool pushEnabled;
  final bool pushTransactions;
  final bool pushSecurity;
  final bool pushMarketing;
  // Email notification settings
  final bool emailEnabled;
  final bool emailTransactions;
  final bool emailMonthlyStatement;
  final bool emailMarketing;
  // SMS notification settings
  final bool smsEnabled;
  final bool smsTransactions;
  final bool smsSecurity;
  // Thresholds
  final double largeTransactionThreshold;
  final double lowBalanceThreshold;
  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserNotificationPreferences({
    required this.id,
    required this.userId,
    required this.pushEnabled,
    required this.pushTransactions,
    required this.pushSecurity,
    required this.pushMarketing,
    required this.emailEnabled,
    required this.emailTransactions,
    required this.emailMonthlyStatement,
    required this.emailMarketing,
    required this.smsEnabled,
    required this.smsTransactions,
    required this.smsSecurity,
    required this.largeTransactionThreshold,
    required this.lowBalanceThreshold,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Default preferences for new users
  factory UserNotificationPreferences.defaults() {
    final now = DateTime.now();
    return UserNotificationPreferences(
      id: '',
      userId: '',
      pushEnabled: true,
      pushTransactions: true,
      pushSecurity: true,
      pushMarketing: false,
      emailEnabled: true,
      emailTransactions: true,
      emailMonthlyStatement: true,
      emailMarketing: false,
      smsEnabled: true,
      smsTransactions: true,
      smsSecurity: true,
      largeTransactionThreshold: 1000,
      lowBalanceThreshold: 100,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory UserNotificationPreferences.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;
    final channels = payload['channels'] is Map<String, dynamic>
        ? payload['channels'] as Map<String, dynamic>
        : const <String, dynamic>{};
    final categories = payload['categories'] is Map<String, dynamic>
        ? payload['categories'] as Map<String, dynamic>
        : const <String, dynamic>{};

    return UserNotificationPreferences(
      id: payload['id'] as String? ?? '',
      userId: payload['userId'] as String? ?? '',
      pushEnabled:
          payload['pushEnabled'] as bool? ?? channels['push'] as bool? ?? true,
      pushTransactions:
          payload['pushTransactions'] as bool? ??
          categories['transaction'] as bool? ??
          true,
      pushSecurity:
          payload['pushSecurity'] as bool? ??
          categories['security'] as bool? ??
          true,
      pushMarketing:
          payload['pushMarketing'] as bool? ??
          categories['marketing'] as bool? ??
          false,
      emailEnabled:
          payload['emailEnabled'] as bool? ??
          channels['email'] as bool? ??
          true,
      emailTransactions:
          payload['emailTransactions'] as bool? ??
          categories['transaction'] as bool? ??
          true,
      emailMonthlyStatement:
          payload['emailMonthlyStatement'] as bool? ??
          categories['system'] as bool? ??
          true,
      emailMarketing:
          payload['emailMarketing'] as bool? ??
          categories['marketing'] as bool? ??
          false,
      smsEnabled:
          payload['smsEnabled'] as bool? ?? channels['sms'] as bool? ?? true,
      smsTransactions:
          payload['smsTransactions'] as bool? ??
          categories['transaction'] as bool? ??
          true,
      smsSecurity:
          payload['smsSecurity'] as bool? ??
          categories['security'] as bool? ??
          true,
      largeTransactionThreshold:
          (payload['largeTransactionThreshold'] as num?)?.toDouble() ?? 1000,
      lowBalanceThreshold:
          (payload['lowBalanceThreshold'] as num?)?.toDouble() ?? 100,
      createdAt: payload['createdAt'] != null
          ? DateTime.parse(payload['createdAt'] as String)
          : DateTime.now(),
      updatedAt: payload['updatedAt'] != null
          ? DateTime.parse(payload['updatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'pushEnabled': pushEnabled,
      'pushTransactions': pushTransactions,
      'pushSecurity': pushSecurity,
      'pushMarketing': pushMarketing,
      'emailEnabled': emailEnabled,
      'emailTransactions': emailTransactions,
      'emailMonthlyStatement': emailMonthlyStatement,
      'emailMarketing': emailMarketing,
      'smsEnabled': smsEnabled,
      'smsTransactions': smsTransactions,
      'smsSecurity': smsSecurity,
      'largeTransactionThreshold': largeTransactionThreshold,
      'lowBalanceThreshold': lowBalanceThreshold,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Returns a map suitable for API update requests (excludes id, userId, timestamps)
  Map<String, dynamic> toUpdateJson() {
    return {
      'channels': {
        'push': pushEnabled,
        'email': emailEnabled,
        'sms': smsEnabled,
        'inApp': true,
      },
      'categories': {
        'transaction': pushTransactions || emailTransactions || smsTransactions,
        'security': pushSecurity || smsSecurity,
        'marketing': pushMarketing || emailMarketing,
        'system': emailMonthlyStatement,
        'kyc': true,
        'risk': true,
        'referral': true,
      },
    };
  }

  UserNotificationPreferences copyWith({
    String? id,
    String? userId,
    bool? pushEnabled,
    bool? pushTransactions,
    bool? pushSecurity,
    bool? pushMarketing,
    bool? emailEnabled,
    bool? emailTransactions,
    bool? emailMonthlyStatement,
    bool? emailMarketing,
    bool? smsEnabled,
    bool? smsTransactions,
    bool? smsSecurity,
    double? largeTransactionThreshold,
    double? lowBalanceThreshold,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserNotificationPreferences(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      pushEnabled: pushEnabled ?? this.pushEnabled,
      pushTransactions: pushTransactions ?? this.pushTransactions,
      pushSecurity: pushSecurity ?? this.pushSecurity,
      pushMarketing: pushMarketing ?? this.pushMarketing,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      emailTransactions: emailTransactions ?? this.emailTransactions,
      emailMonthlyStatement:
          emailMonthlyStatement ?? this.emailMonthlyStatement,
      emailMarketing: emailMarketing ?? this.emailMarketing,
      smsEnabled: smsEnabled ?? this.smsEnabled,
      smsTransactions: smsTransactions ?? this.smsTransactions,
      smsSecurity: smsSecurity ?? this.smsSecurity,
      largeTransactionThreshold:
          largeTransactionThreshold ?? this.largeTransactionThreshold,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserNotificationPreferences &&
        other.id == id &&
        other.userId == userId &&
        other.pushEnabled == pushEnabled &&
        other.pushTransactions == pushTransactions &&
        other.pushSecurity == pushSecurity &&
        other.pushMarketing == pushMarketing &&
        other.emailEnabled == emailEnabled &&
        other.emailTransactions == emailTransactions &&
        other.emailMonthlyStatement == emailMonthlyStatement &&
        other.emailMarketing == emailMarketing &&
        other.smsEnabled == smsEnabled &&
        other.smsTransactions == smsTransactions &&
        other.smsSecurity == smsSecurity &&
        other.largeTransactionThreshold == largeTransactionThreshold &&
        other.lowBalanceThreshold == lowBalanceThreshold;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      userId,
      pushEnabled,
      pushTransactions,
      pushSecurity,
      pushMarketing,
      emailEnabled,
      emailTransactions,
      emailMonthlyStatement,
      emailMarketing,
      smsEnabled,
      smsTransactions,
      smsSecurity,
      largeTransactionThreshold,
      lowBalanceThreshold,
    );
  }
}
