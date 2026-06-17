import 'package:usdc_wallet/utils/phone_normalizer.dart';

String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

String localPhoneDigits({
  required String dialCode,
  required String phoneNumber,
}) => PhoneNormalizer.localDigits(phoneNumber, countryCode: dialCode);

String normalizePhoneE164({
  required String dialCode,
  required String localNumber,
}) => PhoneNormalizer.toE164(localNumber, countryCode: dialCode);
