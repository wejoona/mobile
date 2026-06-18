// Deposit request models.
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

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
