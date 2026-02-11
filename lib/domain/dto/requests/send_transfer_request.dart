/// Request DTO for sending a transfer.
class SendTransferRequest {
  final String recipientPhone;
  final double amount;
  final String currency;
  final String? description;
  final String? idempotencyKey;

  const SendTransferRequest({
    required this.recipientPhone,
    required this.amount,
    this.currency = 'USDC',
    this.description,
    this.idempotencyKey,
  });

  Map<String, dynamic> toJson() => {
        'recipientPhone': recipientPhone,
        'amount': amount,
        'currency': currency,
        if (description != null) 'description': description,
        if (idempotencyKey != null) 'idempotencyKey': idempotencyKey,
      };
}
