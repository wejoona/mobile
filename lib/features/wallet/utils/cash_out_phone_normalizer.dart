import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

String? normalizeCashOutPhone({
  required String phoneNumber,
  required String? countryCode,
}) {
  if (!hasCashOutPhoneCountryContext(phoneNumber, countryCode)) {
    return null;
  }
  return PhoneNumberValue.tryFromAny(
    phoneNumber: phoneNumber,
    countryCode: countryCode,
  )?.e164;
}

bool hasCashOutPhoneCountryContext(String phoneNumber, String? countryCode) {
  if (countryCode != null && countryCode.trim().isNotEmpty) return true;

  final trimmed = phoneNumber.trim();
  if (trimmed.contains('|')) return true;
  if (trimmed.startsWith('+')) return true;

  final digits = digitsOnly(trimmed);
  return digits.startsWith('00');
}
