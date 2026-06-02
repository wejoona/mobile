/// Deposit Request Models

/// Initiate Deposit Request
class InitiateDepositRequest {
  final int amount;
  final String provider;
  final String phoneNumber;
  final String currency;

  const InitiateDepositRequest({
    required this.amount,
    required this.provider,
    required this.phoneNumber,
    required this.currency,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'providerCode': provider,
    if (phoneNumber.isNotEmpty)
      'phoneNumber': _normalizePhoneNumber(phoneNumber, currency),
  };
}

String _normalizePhoneNumber(String phoneNumber, String currency) {
  final trimmed = phoneNumber.trim().replaceAll(' ', '');
  if (trimmed.startsWith('+')) return trimmed;

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return '';

  if (currency == 'XOF') {
    if (digits.startsWith('225')) return '+$digits';
    return '+225$digits';
  }

  if (currency == 'USD' && digits.length == 10) {
    return '+1$digits';
  }

  return '+$digits';
}

/// Confirm Deposit Request
class ConfirmDepositRequest {
  final String token;
  final String? otp;

  const ConfirmDepositRequest({required this.token, this.otp});

  Map<String, dynamic> toJson() => {
    'token': token,
    if (otp != null) 'otp': otp,
  };
}

/// Legacy DepositRequest (keeping for backward compatibility)
typedef DepositRequest = InitiateDepositRequest;
