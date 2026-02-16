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
  final String? nextTierName;
  final double? nextTierDailyLimit;
  final double? nextTierMonthlyLimit;
  final DateTime? resetTime;
  final int? hoursUntilReset;
  final int? minutesUntilReset;

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
    this.nextTierName,
    this.nextTierDailyLimit,
    this.nextTierMonthlyLimit,
    this.resetTime,
    this.hoursUntilReset,
    this.minutesUntilReset,
  });

  factory TransactionLimits.fromJson(Map<String, dynamic> json) {
    return TransactionLimits(
      dailyLimit: (json['dailyLimit'] as num?)?.toDouble() ?? 0.0,
      weeklyLimit: (json['weeklyLimit'] as num?)?.toDouble() ?? 0.0,
      monthlyLimit: (json['monthlyLimit'] as num?)?.toDouble() ?? 0.0,
      singleTransactionLimit: (json['singleTransactionLimit'] as num?)?.toDouble() ?? 0.0,
      singleTransactionMax: (json['singleTransactionMax'] as num?)?.toDouble() ?? (json['singleTransactionLimit'] as num?)?.toDouble() ?? 0.0,
      withdrawalLimit: (json['withdrawalLimit'] as num?)?.toDouble() ?? 0.0,
      dailyUsed: (json['dailyUsed'] as num?)?.toDouble() ?? 0.0,
      weeklyUsed: (json['weeklyUsed'] as num?)?.toDouble() ?? 0.0,
      monthlyUsed: (json['monthlyUsed'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USDC',
      kycTier: (json['kycTier'] as num?)?.toInt() ?? 0,
      tierName: json['tierName'] as String? ?? 'Basic',
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
    'nextTierName': nextTierName,
    'nextTierDailyLimit': nextTierDailyLimit,
    'nextTierMonthlyLimit': nextTierMonthlyLimit,
    'resetTime': resetTime?.toIso8601String(),
    'hoursUntilReset': hoursUntilReset,
    'minutesUntilReset': minutesUntilReset,
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
    String? nextTierName,
    double? nextTierDailyLimit,
    double? nextTierMonthlyLimit,
    DateTime? resetTime,
    int? hoursUntilReset,
    int? minutesUntilReset,
  }) {
    return TransactionLimits(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      singleTransactionLimit: singleTransactionLimit ?? this.singleTransactionLimit,
      withdrawalLimit: withdrawalLimit ?? this.withdrawalLimit,
      dailyUsed: dailyUsed ?? this.dailyUsed,
      monthlyUsed: monthlyUsed ?? this.monthlyUsed,
      kycTier: kycTier ?? this.kycTier,
      tierName: tierName ?? this.tierName,
      nextTierName: nextTierName ?? this.nextTierName,
      nextTierDailyLimit: nextTierDailyLimit ?? this.nextTierDailyLimit,
      nextTierMonthlyLimit: nextTierMonthlyLimit ?? this.nextTierMonthlyLimit,
      resetTime: resetTime ?? this.resetTime,
      hoursUntilReset: hoursUntilReset ?? this.hoursUntilReset,
      minutesUntilReset: minutesUntilReset ?? this.minutesUntilReset,
    );
  }

  // Helper getters
  double get dailyRemaining => (dailyLimit - dailyUsed).clamp(0.0, dailyLimit);
  double get monthlyRemaining => (monthlyLimit - monthlyUsed).clamp(0.0, monthlyLimit);
  double get dailyPercentage => dailyLimit > 0 ? (dailyUsed / dailyLimit).clamp(0.0, 1.0) : 0.0;
  double get monthlyPercentage => monthlyLimit > 0 ? (monthlyUsed / monthlyLimit).clamp(0.0, 1.0) : 0.0;
  bool get isDailyNearLimit => dailyPercentage >= 0.8;
  bool get isDailyAtLimit => dailyPercentage >= 1.0;
  bool get isMonthlyNearLimit => monthlyPercentage >= 0.8;
  bool get isMonthlyAtLimit => monthlyPercentage >= 1.0;
  bool get hasNextTier => nextTierName != null;
  double get effectiveMax => [dailyRemaining, monthlyRemaining, singleTransactionLimit].where((v) => v > 0).reduce((a, b) => a < b ? a : b);
  String? limitHitBy(double amount) {
    if (amount > singleTransactionLimit && singleTransactionLimit > 0) return 'single_transaction';
    if (amount > dailyRemaining) return 'daily';
    if (amount > monthlyRemaining) return 'monthly';
    return null;
  }
}
