/// Request DTO for initiating a deposit.
class DepositRequest {
  final double amount;
  final String currency;
  final String method;
  final String? mobileMoneyNumber;
  final String? bankAccountId;
  final String? idempotencyKey;

  const DepositRequest({
    required this.amount,
    this.currency = 'USDC',
    required this.method,
    this.mobileMoneyNumber,
    this.bankAccountId,
    this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'method': method,
        if (mobileMoneyNumber != null) 'mobileMoneyNumber': mobileMoneyNumber,
        if (bankAccountId != null) 'bankAccountId': bankAccountId,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      };
}
