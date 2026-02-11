/// Savings pot entity - mirrors backend SavingsPot domain entity.
class SavingsPot {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime? targetDate;
  final bool isLocked;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SavingsPot({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    this.currency = 'USDC',
    this.targetDate,
    this.isLocked = false,
    required this.createdAt,
    this.updatedAt,
  });

  /// Progress toward goal (0.0 to 1.0).
  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  /// Progress as percentage (0 to 100).
  int get progressPercent => (progress * 100).round();

  /// Remaining amount to reach goal.
  double get remaining => (targetAmount - currentAmount).clamp(0, targetAmount);

  /// Whether the goal has been reached.
  bool get isGoalReached => currentAmount >= targetAmount;

  /// Whether the target date has passed.
  bool get isOverdue =>
      targetDate != null && DateTime.now().isAfter(targetDate!);

  /// Days remaining until target date.
  int? get daysRemaining =>
      targetDate?.difference(DateTime.now()).inDays;

  factory SavingsPot.fromJson(Map<String, dynamic> json) {
    return SavingsPot(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0,
      currency: json['currency'] as String? ?? 'USDC',
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
      isLocked: json['isLocked'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'currency': currency,
        'targetDate': targetDate?.toIso8601String(),
        'isLocked': isLocked,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
