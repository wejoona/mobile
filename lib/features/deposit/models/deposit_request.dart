import 'package:usdc_wallet/features/deposit/models/deposit_channel_id.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

// Deposit request models.
export 'package:usdc_wallet/features/deposit/models/deposit_channel_id.dart'
    show
        depositChannelIdFromJson,
        normalizeDepositChannelId,
        normalizeDepositProviderCode;

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

  Map<String, dynamic> toJson() {
    final normalizedPhoneNumber = _normalizePhoneNumber(phoneNumber, currency);
    return {
      'amount': amount,
      'currency': currency,
      'providerCode': normalizeDepositProviderCode(provider),
      if (normalizedPhoneNumber != null) 'phoneNumber': normalizedPhoneNumber,
    };
  }

  Map<String, dynamic> toWalletDepositJson() {
    final normalizedPhoneNumber = _normalizePhoneNumber(phoneNumber, currency);
    return {
      'amount': amount,
      'sourceCurrency': currency,
      'channelId': normalizeDepositChannelId(provider),
      if (normalizedPhoneNumber != null) 'phoneNumber': normalizedPhoneNumber,
    };
  }
}

String? _normalizePhoneNumber(String phoneNumber, String currency) {
  final phoneValue = PhoneNumberValue.tryFromAny(
    phoneNumber: phoneNumber,
    countryCode: _countryCodeForDepositCurrency(currency),
  );
  return phoneValue?.e164;
}

String? _countryCodeForDepositCurrency(String currency) {
  switch (currency.trim().toUpperCase()) {
    case 'XOF':
      return 'CI';
    case 'USD':
      return 'US';
    default:
      return null;
  }
}

/// Legacy DepositRequest (keeping for backward compatibility)
typedef DepositRequest = InitiateDepositRequest;
