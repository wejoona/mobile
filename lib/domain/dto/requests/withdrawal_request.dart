/// Request DTO for initiating a withdrawal.
class WithdrawalRequest {
  final double amount;
  final String currency;
  final String method;
  final String? mobileMoneyNumber;
  final String? bankAccountId;
  final String? destinationAddress;

  const WithdrawalRequest({
    required this.amount,
    this.currency = 'USDC',
    required this.method,
    this.mobileMoneyNumber,
    this.bankAccountId,
    this.destinationAddress,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'method': method,
        if (mobileMoneyNumber != null) 'mobileMoneyNumber': mobileMoneyNumber,
        if (bankAccountId != null) 'bankAccountId': bankAccountId,
        if (destinationAddress != null) 'destinationAddress': destinationAddress,
      };
}
