class UpcomingExecution {
  final String recurringTransferId;
  final String recipientName;
  final double amount;
  final String currency;
  final DateTime scheduledDate;

  const UpcomingExecution({
    required this.recurringTransferId,
    required this.recipientName,
    required this.amount,
    required this.currency,
    required this.scheduledDate,
  });

  factory UpcomingExecution.fromJson(Map<String, dynamic> json) {
    return UpcomingExecution(
      recurringTransferId: json['recurringTransferId'] as String,
      recipientName: json['recipientName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'recurringTransferId': recurringTransferId,
    'recipientName': recipientName,
    'amount': amount,
    'currency': currency,
    'scheduledDate': scheduledDate.toIso8601String(),
  };

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return scheduledDate.year == tomorrow.year &&
        scheduledDate.month == tomorrow.month &&
        scheduledDate.day == tomorrow.day;
  }
}
