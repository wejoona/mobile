/// Request DTO for creating a virtual card.
class CreateCardRequest {
  final String type;
  final String? nickname;
  final double? spendingLimit;
  final String currency;

  const CreateCardRequest({
    this.type = 'virtual',
    this.nickname,
    this.spendingLimit,
    this.currency = 'USDC',
  });

  Map<String, dynamic> toJson() => {
        'type': type,
        if (nickname != null) 'nickname': nickname,
        if (spendingLimit != null) 'spendingLimit': spendingLimit,
        'currency': currency,
      };
}
