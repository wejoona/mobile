/// Request DTO for creating a payment link.
class CreatePaymentLinkRequest {
  final double? amount;
  final String currency;
  final String? description;
  final bool isReusable;
  final DateTime? expiresAt;
  final int? maxUses;

  const CreatePaymentLinkRequest({
    this.amount,
    this.currency = 'USDC',
    this.description,
    this.isReusable = false,
    this.expiresAt,
    this.maxUses,
  });

  Map<String, dynamic> toJson() => {
        if (amount != null) 'amount': amount,
        'currency': currency,
        if (description != null) 'description': description,
        'isReusable': isReusable,
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        if (maxUses != null) 'maxUses': maxUses,
      };
}
