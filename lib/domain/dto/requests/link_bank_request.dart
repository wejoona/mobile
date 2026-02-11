/// Request DTO for linking a bank account.
class LinkBankRequest {
  final String bankName;
  final String accountNumber;
  final String? accountName;
  final String? routingNumber;
  final String accountType;
  final String currency;
  final bool setAsDefault;

  const LinkBankRequest({
    required this.bankName,
    required this.accountNumber,
    this.accountName,
    this.routingNumber,
    this.accountType = 'checking',
    this.currency = 'XOF',
    this.setAsDefault = false,
  });

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'accountNumber': accountNumber,
        if (accountName != null) 'accountName': accountName,
        if (routingNumber != null) 'routingNumber': routingNumber,
        'accountType': accountType,
        'currency': currency,
        'setAsDefault': setAsDefault,
      };
}
