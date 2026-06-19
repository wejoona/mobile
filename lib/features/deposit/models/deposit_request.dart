import 'package:usdc_wallet/features/deposit/models/deposit_channel_id.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';
import 'package:usdc_wallet/utils/phone_normalizer.dart';

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
  final String? countryCode;

  const InitiateDepositRequest({
    required this.amount,
    required this.provider,
    required this.phoneNumber,
    required this.currency,
    this.countryCode,
  });

  Map<String, dynamic> toJson() {
    final normalizedCountryCode = _normalizeCountryCode(countryCode);
    final normalizedPhoneNumber = _normalizePhoneNumber(
      phoneNumber,
      currency,
      normalizedCountryCode,
    );
    return {
      'amount': amount,
      'currency': currency,
      'providerCode': normalizeDepositProviderCode(provider),
      if (normalizedCountryCode != null) 'countryCode': normalizedCountryCode,
      if (normalizedPhoneNumber != null) 'phoneNumber': normalizedPhoneNumber,
    };
  }

  Map<String, dynamic> toWalletDepositJson() {
    final normalizedCountryCode = _normalizeCountryCode(countryCode);
    final normalizedPhoneNumber = _normalizePhoneNumber(
      phoneNumber,
      currency,
      normalizedCountryCode,
    );
    return {
      'amount': amount,
      'sourceCurrency': currency,
      'channelId': normalizeDepositChannelId(provider),
      if (normalizedPhoneNumber != null) 'phoneNumber': normalizedPhoneNumber,
    };
  }
}

String? _normalizePhoneNumber(
  String phoneNumber,
  String currency,
  String? countryCode,
) {
  final phoneValue = PhoneNumberValue.tryFromAny(
    phoneNumber: phoneNumber,
    countryCode: countryCode ?? _countryCodeForDepositCurrency(currency),
  );
  return phoneValue?.e164;
}

String? _normalizeCountryCode(String? countryCode) {
  final value = countryCode?.trim();
  if (value == null || value.isEmpty) {
    return null;
  }
  final country = PhoneNormalizer.countryFromCode(value);
  return country?.code ?? value.toUpperCase();
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
