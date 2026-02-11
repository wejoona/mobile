/// Request DTO for paying a bill.
class BillPaymentRequest {
  final String billerId;
  final String billerName;
  final String accountNumber;
  final double amount;
  final String currency;
  final String? reference;

  const BillPaymentRequest({
    required this.billerId,
    required this.billerName,
    required this.accountNumber,
    required this.amount,
    this.currency = 'XOF',
    this.reference,
  });

  Map<String, dynamic> toJson() => {
        'billerId': billerId,
        'billerName': billerName,
        'accountNumber': accountNumber,
        'amount': amount,
        'currency': currency,
        if (reference != null) 'reference': reference,
      };
}
