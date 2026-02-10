/// Deposit Request Models

/// Initiate Deposit Request
class InitiateDepositRequest {
  final int amount;
  final String currency;
  final String providerCode;
  final String? phoneNumber;

  const InitiateDepositRequest({
    required this.amount,
    this.currency = 'XOF',
    required this.providerCode,
    this.phoneNumber,
  });

  Map<String, dynamic> toJson() => {
        'amount': amount,
        'currency': currency,
        'providerCode': providerCode,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
      };
}

/// Confirm Deposit Request
class ConfirmDepositRequest {
  final String token;
  final String? otp;

  const ConfirmDepositRequest({
    required this.token,
    this.otp,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        if (otp != null) 'otp': otp,
      };
}

/// Legacy DepositRequest (keeping for backward compatibility)
typedef DepositRequest = InitiateDepositRequest;
