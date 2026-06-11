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
    'providerCode': normalizeDepositProviderCode(provider),
    if (phoneNumber.isNotEmpty)
      'phoneNumber': _normalizePhoneNumber(phoneNumber, currency),
  };

  Map<String, dynamic> toWalletDepositJson() => {
    'amount': amount,
    'sourceCurrency': currency,
    'channelId': normalizeDepositChannelId(provider),
    if (phoneNumber.isNotEmpty)
      'phoneNumber': _normalizePhoneNumber(phoneNumber, currency),
  };
}

String normalizeDepositChannelId(String value) {
  switch (value.replaceAll('-', '_').toLowerCase()) {
    case 'orange_money_ci':
    case 'omci':
    case 'orange':
    case 'orange_money':
    case 'mobile_money':
      return 'orange_money_ci';
    case 'mtn_momo_ci':
    case 'mtnci':
    case 'mtn':
    case 'mtn_momo':
    case 'mtn_mobile_money':
      return 'mtn_momo_ci';
    case 'moov_money_ci':
    case 'moovci':
    case 'moov':
    case 'moov_money':
      return 'moov_money_ci';
    case 'wave_ci':
    case 'waveci':
    case 'wave':
      return 'wave_ci';
    default:
      return value;
  }
}

String normalizeDepositProviderCode(String value) {
  switch (value.replaceAll('-', '_').toLowerCase()) {
    case 'omci':
    case 'orange':
    case 'orange_money':
    case 'orange_money_ci':
    case 'mobile_money':
      return 'OMCI';
    case 'mtnci':
    case 'mtn':
    case 'mtn_momo':
    case 'mtn_momo_ci':
    case 'mtn_mobile_money':
      return 'MTNCI';
    case 'moovci':
    case 'moov':
    case 'moov_money':
    case 'moov_money_ci':
      return 'MOOVCI';
    case 'waveci':
    case 'wave':
    case 'wave_ci':
      return 'WAVECI';
    default:
      return value.toUpperCase();
  }
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

/// Legacy DepositRequest (keeping for backward compatibility)
typedef DepositRequest = InitiateDepositRequest;
