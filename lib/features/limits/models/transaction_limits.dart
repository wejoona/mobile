class TransactionLimits {
  final double dailyLimit;
  final double monthlyLimit;
  final double dailyUsed;
  final double monthlyUsed;
  final int kycTier;
  final String tierName;
  final String? nextTierName;
  final double? nextTierDailyLimit;
  final double? nextTierMonthlyLimit;

  const TransactionLimits({
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.dailyUsed,
    required this.monthlyUsed,
    required this.kycTier,
    required this.tierName,
    this.nextTierName,
    this.nextTierDailyLimit,
    this.nextTierMonthlyLimit,
  });

  factory TransactionLimits.fromJson(Map<String, dynamic> json) {
    return TransactionLimits(
      dailyLimit: (json['dailyLimit'] as num).toDouble(),
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      dailyUsed: (json['dailyUsed'] as num).toDouble(),
      monthlyUsed: (json['monthlyUsed'] as num).toDouble(),
      kycTier: json['kycTier'] as int,
      tierName: json['tierName'] as String,
      nextTierName: json['nextTierName'] as String?,
      nextTierDailyLimit: json['nextTierDailyLimit'] != null
          ? (json['nextTierDailyLimit'] as num).toDouble()
          : null,
      nextTierMonthlyLimit: json['nextTierMonthlyLimit'] != null
          ? (json['nextTierMonthlyLimit'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'dailyLimit': dailyLimit,
    'monthlyLimit': monthlyLimit,
    'dailyUsed': dailyUsed,
    'monthlyUsed': monthlyUsed,
    'kycTier': kycTier,
    'tierName': tierName,
    'nextTierName': nextTierName,
    'nextTierDailyLimit': nextTierDailyLimit,
    'nextTierMonthlyLimit': nextTierMonthlyLimit,
  };

  TransactionLimits copyWith({
    double? dailyLimit,
    double? monthlyLimit,
    double? dailyUsed,
    double? monthlyUsed,
    int? kycTier,
    String? tierName,
    String? nextTierName,
    double? nextTierDailyLimit,
    double? nextTierMonthlyLimit,
  }) {
    return TransactionLimits(
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      dailyUsed: dailyUsed ?? this.dailyUsed,
      monthlyUsed: monthlyUsed ?? this.monthlyUsed,
      kycTier: kycTier ?? this.kycTier,
      tierName: tierName ?? this.tierName,
      nextTierName: nextTierName ?? this.nextTierName,
      nextTierDailyLimit: nextTierDailyLimit ?? this.nextTierDailyLimit,
      nextTierMonthlyLimit: nextTierMonthlyLimit ?? this.nextTierMonthlyLimit,
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
}
