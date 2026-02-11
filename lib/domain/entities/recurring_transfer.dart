/// Recurring transfer entity - mirrors backend RecurringTransfer domain entity.
class RecurringTransfer {
  final String id;
  final String userId;
  final String recipientPhone;
  final String? recipientName;
  final double amount;
  final String currency;
  final RecurringFrequency frequency;
  final RecurringStatus status;
  final DateTime? nextExecutionDate;
  final DateTime? lastExecutionDate;
  final int executionCount;
  final int? maxExecutions;
  final String? note;
  final DateTime createdAt;

  const RecurringTransfer({
    required this.id,
    required this.userId,
    required this.recipientPhone,
    this.recipientName,
    required this.amount,
    this.currency = 'USDC',
    required this.frequency,
    required this.status,
    this.nextExecutionDate,
    this.lastExecutionDate,
    this.executionCount = 0,
    this.maxExecutions,
    this.note,
    required this.createdAt,
  });

  bool get isActive => status == RecurringStatus.active;
  bool get isPaused => status == RecurringStatus.paused;

  /// Whether max executions limit has been reached.
  bool get isCompleted =>
      maxExecutions != null && executionCount >= maxExecutions!;

  /// Display-friendly frequency label.
  String get frequencyLabel {
    switch (frequency) {
      case RecurringFrequency.daily:
        return 'Daily';
      case RecurringFrequency.weekly:
        return 'Weekly';
      case RecurringFrequency.biweekly:
        return 'Every 2 weeks';
      case RecurringFrequency.monthly:
        return 'Monthly';
      case RecurringFrequency.quarterly:
        return 'Quarterly';
    }
  }

  factory RecurringTransfer.fromJson(Map<String, dynamic> json) {
    return RecurringTransfer(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      recipientPhone: json['recipientPhone'] as String,
      recipientName: json['recipientName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      frequency: RecurringFrequency.values.firstWhere(
        (e) => e.name == json['frequency'],
        orElse: () => RecurringFrequency.monthly,
      ),
      status: RecurringStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => RecurringStatus.active,
      ),
      nextExecutionDate: json['nextExecutionDate'] != null
          ? DateTime.parse(json['nextExecutionDate'] as String)
          : null,
      lastExecutionDate: json['lastExecutionDate'] != null
          ? DateTime.parse(json['lastExecutionDate'] as String)
          : null,
      executionCount: json['executionCount'] as int? ?? 0,
      maxExecutions: json['maxExecutions'] as int?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipientPhone': recipientPhone,
        'amount': amount,
        'currency': currency,
        'frequency': frequency.name,
        'note': note,
        'maxExecutions': maxExecutions,
      };
}

enum RecurringFrequency { daily, weekly, biweekly, monthly, quarterly }

enum RecurringStatus { active, paused, cancelled, completed }
