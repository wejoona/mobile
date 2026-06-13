class TransactionLimits {
  final double dailyLimit;
  final double weeklyLimit;
  final double monthlyLimit;
  final double singleTransactionLimit;
  final double singleTransactionMax;
  final double withdrawalLimit;
  final double dailyUsed;
  final double weeklyUsed;
  final double monthlyUsed;
  final String currency;
  final int kycTier;
  final String tierName;
  final String? kycStatus;
  final String? upgradeMessage;
  final String? nextTierName;
  final double? nextTierDailyLimit;
  final double? nextTierMonthlyLimit;
  final DateTime? resetTime;
  final int? hoursUntilReset;
  final int? minutesUntilReset;
  final bool overrideActive;
  final String? overrideReason;
  final DateTime? overrideExpiresAt;

  const TransactionLimits({
    required this.dailyLimit,
    this.weeklyLimit = 0,
    required this.monthlyLimit,
    required this.singleTransactionLimit,
    this.singleTransactionMax = 0,
    required this.withdrawalLimit,
    required this.dailyUsed,
    this.weeklyUsed = 0,
    required this.monthlyUsed,
    this.currency = 'USDC',
    required this.kycTier,
    required this.tierName,
    this.kycStatus,
    this.upgradeMessage,
    this.nextTierName,
    this.nextTierDailyLimit,
    this.nextTierMonthlyLimit,
    this.resetTime,
    this.hoursUntilReset,
    this.minutesUntilReset,
    this.overrideActive = false,
    this.overrideReason,
    this.overrideExpiresAt,
  });

  factory TransactionLimits.fromJson(Map<String, dynamic> json) {
    return TransactionLimits(
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 0.0,
      weeklyLimit: (json['weeklyLimit'] as num?)?.toDouble() ?? 0.0,
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      singleTransactionLimit:
          (json['singleTransactionLimit'] as num?)?.toDouble() ?? 0.0,
      singleTransactionMax:
          (json['singleTransactionMax'] as num?)?.toDouble() ??
          (json['singleTransactionLimit'] as num?)?.toDouble() ??
          0.0,
      withdrawalLimit: (json['withdrawalLimit'] as num?)?.toDouble() ?? 0.0,
      dailyUsed: (json['dailyUsed'] as num?)?.toDouble() ?? 0.0,
      weeklyUsed: (json['weeklyUsed'] as num?)?.toDouble() ?? 0.0,
      monthlyUsed: (json['monthlyUsed'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USDC',
      kycTier: (json['kycTier'] as num?)?.toInt() ?? 0,
      tierName: json['tierName'] as String? ?? 'Basic',
      kycStatus: json['kycStatus'] as String?,
      upgradeMessage: json['upgradeMessage'] as String?,
      nextTierName: json['nextTierName'] as String?,
      nextTierDailyLimit: json['nextTierDailyLimit'] != null
          ? (json['nextTierDailyLimit'] as num).toDouble()
          : null,
      nextTierMonthlyLimit: json['nextTierMonthlyLimit'] != null
          ? (json['nextTierMonthlyLimit'] as num).toDouble()
          : null,
      resetTime: json['resetTime'] != null
          ? DateTime.parse(json['resetTime'] as String)
          : null,
      hoursUntilReset: json['hoursUntilReset'] as int?,
      minutesUntilReset: json['minutesUntilReset'] as int?,
      overrideActive: json['overrideActive'] as bool? ?? false,
      overrideReason: json['overrideReason'] as String?,
      overrideExpiresAt: json['overrideExpiresAt'] != null
          ? DateTime.parse(json['overrideExpiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyLimit': dailyLimit,
    'monthlyLimit': monthlyLimit,
    'singleTransactionLimit': singleTransactionLimit,
    'withdrawalLimit': withdrawalLimit,
    'dailyUsed': dailyUsed,
    'monthlyUsed': monthlyUsed,
    'kycTier': kycTier,
    'tierName': tierName,
    'kycStatus': kycStatus,
    'upgradeMessage': upgradeMessage,
    'nextTierName': nextTierName,
    'nextTierDailyLimit': nextTierDailyLimit,
    'nextTierMonthlyLimit': nextTierMonthlyLimit,
    'resetTime': resetTime?.toIso8601String(),
    'hoursUntilReset': hoursUntilReset,
    'minutesUntilReset': minutesUntilReset,
    'overrideActive': overrideActive,
    'overrideReason': overrideReason,
    'overrideExpiresAt': overrideExpiresAt?.toIso8601String(),
  };

  TransactionLimits copyWith({
    double? dailyLimit,
    double? monthlyLimit,
    double? singleTransactionLimit,
    double? withdrawalLimit,
    double? dailyUsed,
    double? monthlyUsed,
    int? kycTier,
    String? tierName,
    String? kycStatus,
    String? upgradeMessage,
    String? nextTierName,
    double? nextTierDailyLimit,
    double? nextTierMonthlyLimit,
    DateTime? resetTime,
    int? hoursUntilReset,
    int? minutesUntilReset,
    bool? overrideActive,
    String? overrideReason,
    DateTime? overrideExpiresAt,
  }) {
    return TransactionLimits(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      singleTransactionLimit:
          singleTransactionLimit ?? this.singleTransactionLimit,
      withdrawalLimit: withdrawalLimit ?? this.withdrawalLimit,
      dailyUsed: dailyUsed ?? this.dailyUsed,
      monthlyUsed: monthlyUsed ?? this.monthlyUsed,
      kycTier: kycTier ?? this.kycTier,
      tierName: tierName ?? this.tierName,
      kycStatus: kycStatus ?? this.kycStatus,
      upgradeMessage: upgradeMessage ?? this.upgradeMessage,
      nextTierName: nextTierName ?? this.nextTierName,
      nextTierDailyLimit: nextTierDailyLimit ?? this.nextTierDailyLimit,
      nextTierMonthlyLimit: nextTierMonthlyLimit ?? this.nextTierMonthlyLimit,
      resetTime: resetTime ?? this.resetTime,
      hoursUntilReset: hoursUntilReset ?? this.hoursUntilReset,
      minutesUntilReset: minutesUntilReset ?? this.minutesUntilReset,
      overrideActive: overrideActive ?? this.overrideActive,
      overrideReason: overrideReason ?? this.overrideReason,
      overrideExpiresAt: overrideExpiresAt ?? this.overrideExpiresAt,
    );
  }

  // Helper getters
  double get dailyRemaining => (dailyLimit - dailyUsed).clamp(0.0, dailyLimit);
  double get monthlyRemaining =>
      (monthlyLimit - monthlyUsed).clamp(0.0, monthlyLimit);
  double get dailyPercentage =>
      dailyLimit > 0 ? (dailyUsed / dailyLimit).clamp(0.0, 1.0) : 0.0;
  double get monthlyPercentage =>
      monthlyLimit > 0 ? (monthlyUsed / monthlyLimit).clamp(0.0, 1.0) : 0.0;
  bool get isDailyNearLimit => dailyPercentage >= 0.8;
  bool get isDailyAtLimit => dailyPercentage >= 1.0;
  bool get isMonthlyNearLimit => monthlyPercentage >= 0.8;
  bool get isMonthlyAtLimit => monthlyPercentage >= 1.0;
  bool get hasNextTier => nextTierName != null;
  bool get hasActiveOverride => overrideActive;
  double get effectiveMax {
    final candidates = [
      dailyRemaining,
      monthlyRemaining,
      singleTransactionLimit,
    ].where((value) => value > 0).toList();
    if (candidates.isEmpty) {
      return 0;
    }
    return candidates.reduce((a, b) => a < b ? a : b);
  }

  String? limitHitBy(double amount) {
    if (amount > singleTransactionLimit && singleTransactionLimit > 0) {
      return 'single_transaction';
    }
    if (dailyLimit > 0 && amount > dailyRemaining) {
      return 'daily';
    }
    if (monthlyLimit > 0 && amount > monthlyRemaining) {
      return 'monthly';
    }
    return null;
  }
}
