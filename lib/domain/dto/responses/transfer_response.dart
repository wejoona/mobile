/// Response DTO for a completed transfer.
class TransferResponse {
  final String transactionId;
  final String status;
  final double amount;
  final double fee;
  final String currency;
  final String recipientPhone;
  final DateTime createdAt;

  const TransferResponse({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.fee,
    required this.currency,
    required this.recipientPhone,
    required this.createdAt,
  });

  factory TransferResponse.fromJson(Map<String, dynamic> json) {
    return TransferResponse(
      transactionId: json['transactionId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'USDC',
      recipientPhone: json['recipientPhone'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
