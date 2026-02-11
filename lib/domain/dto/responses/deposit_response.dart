/// Response DTO for a deposit initiation.
class DepositResponse {
  final String transactionId;
  final String status;
  final double amount;
  final String currency;
  final String? paymentUrl;
  final String? mobileMoneyCode;
  final DateTime expiresAt;

  const DepositResponse({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    this.paymentUrl,
    this.mobileMoneyCode,
    required this.expiresAt,
  });

  factory DepositResponse.fromJson(Map<String, dynamic> json) {
    return DepositResponse(
      transactionId: json['transactionId'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USDC',
      paymentUrl: json['paymentUrl'] as String?,
      mobileMoneyCode: json['mobileMoneyCode'] as String?,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
    );
  }
}
