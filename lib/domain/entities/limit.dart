/// User transaction limits entity.
class TransactionLimits {
  final double dailyLimit;
  final double dailyUsed;
  final double weeklyLimit;
  final double weeklyUsed;
  final double monthlyLimit;
  final double monthlyUsed;
  final double singleTransactionMax;
  final String currency;

  const TransactionLimits({
    required this.dailyLimit,
    this.dailyUsed = 0,
    required this.weeklyLimit,
    this.weeklyUsed = 0,
    required this.monthlyLimit,
    this.monthlyUsed = 0,
    required this.singleTransactionMax,
    this.currency = 'USDC',
  });

  /// Remaining daily amount.
  double get dailyRemaining => (dailyLimit - dailyUsed).clamp(0, dailyLimit);

  /// Remaining weekly amount.
  double get weeklyRemaining =>
      (weeklyLimit - weeklyUsed).clamp(0, weeklyLimit);

  /// Remaining monthly amount.
  double get monthlyRemaining =>
      (monthlyLimit - monthlyUsed).clamp(0, monthlyLimit);

  /// Daily usage percentage (0.0 to 1.0).
  double get dailyUsage =>
      dailyLimit > 0 ? (dailyUsed / dailyLimit).clamp(0, 1) : 0;

  /// Effective max for next transaction (lowest of all remaining limits).
  double get effectiveMax => [
        dailyRemaining,
        weeklyRemaining,
        monthlyRemaining,
        singleTransactionMax,
      ].reduce((a, b) => a < b ? a : b);

  /// Whether a given amount would exceed limits.
  bool wouldExceed(double amount) => amount > effectiveMax;

  /// Which limit would be hit first for a given amount.
  String? limitHitBy(double amount) {
    if (amount > singleTransactionMax) return 'single transaction limit';
    if (amount > dailyRemaining) return 'daily limit';
    if (amount > weeklyRemaining) return 'weekly limit';
    if (amount > monthlyRemaining) return 'monthly limit';
    return null;
  }

  factory TransactionLimits.fromJson(Map<String, dynamic> json) {
    return TransactionLimits(
      dailyLimit: (json['dailyLimit'] as num).toDouble(),
      dailyUsed: (json['dailyUsed'] as num?)?.toDouble() ?? 0,
      weeklyLimit: (json['weeklyLimit'] as num).toDouble(),
      weeklyUsed: (json['weeklyUsed'] as num?)?.toDouble() ?? 0,
      monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
      monthlyUsed: (json['monthlyUsed'] as num?)?.toDouble() ?? 0,
      singleTransactionMax:
          (json['singleTransactionMax'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
    );
  }
}
