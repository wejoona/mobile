class ExecutionHistory {
  final String id;
  final String recurringTransferId;
  final double amount;
  final String currency;
  final DateTime executedAt;
  final bool success;
  final String? errorMessage;
  final String? transactionId;

  const ExecutionHistory({
    required this.id,
    required this.recurringTransferId,
    required this.amount,
    required this.currency,
    required this.executedAt,
    required this.success,
    this.errorMessage,
    this.transactionId,
  });

  factory ExecutionHistory.fromJson(Map<String, dynamic> json) {
    return ExecutionHistory(
      id: json['id'] as String,
      recurringTransferId: json['recurringTransferId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      executedAt: DateTime.parse(json['executedAt'] as String),
      success: json['success'] as bool,
      errorMessage: json['errorMessage'] as String?,
      transactionId: json['transactionId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recurringTransferId': recurringTransferId,
    'amount': amount,
    'currency': currency,
    'executedAt': executedAt.toIso8601String(),
    'success': success,
    'errorMessage': errorMessage,
    'transactionId': transactionId,
  };
}
