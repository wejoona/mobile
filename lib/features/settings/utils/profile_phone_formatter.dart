import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

String formatProfilePhone(String? phone) {
  final raw = phone?.trim();
  if (raw == null || raw.isEmpty) return '';

  final phoneValue = PhoneNumberValue.tryFromAny(phoneNumber: raw);
  return phoneValue?.displayInternational ?? raw;
}
