import 'package:usdc_wallet/utils/phone_normalizer.dart';

String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

class PhoneNumberValue {
  const PhoneNumberValue({
    required this.dialCode,
    required this.localNumber,
    required this.isoCountryCode,
  });

  final String dialCode;
  final String localNumber;
  final String isoCountryCode;

  String get e164 =>
      normalizePhoneE164(dialCode: dialCode, localNumber: localNumber);

  String get storageValue => '$dialCode|$localNumber';

  static PhoneNumberValue fromLocal({
    required String dialCode,
    required String localNumber,
  }) {
    final e164 = normalizePhoneE164(
      dialCode: dialCode,
      localNumber: localNumber,
    );
    return PhoneNumberValue(
      dialCode:
          PhoneNormalizer.countryFromCode(dialCode)?.fullPrefix ?? dialCode,
      localNumber: PhoneNormalizer.localDigits(e164, countryCode: dialCode),
      isoCountryCode: PhoneNormalizer.toIsoCountryCode(dialCode, e164),
    );
  }

  static PhoneNumberValue fromAny({
    required String phoneNumber,
    String? countryCode,
  }) {
    final e164 = PhoneNormalizer.toE164(phoneNumber, countryCode: countryCode);
    final country =
        PhoneNormalizer.countryFromCode(countryCode) ??
        PhoneNormalizer.countryFromCode(
          PhoneNormalizer.toIsoCountryCode(countryCode ?? '', e164),
        );
    final dialCode = country?.fullPrefix ?? '+${e164.substring(1, 4)}';

    return PhoneNumberValue(
      dialCode: dialCode,
      localNumber: PhoneNormalizer.localDigits(e164, countryCode: dialCode),
      isoCountryCode: PhoneNormalizer.toIsoCountryCode(
        countryCode ?? dialCode,
        e164,
      ),
    );
  }

  static PhoneNumberValue? tryFromAny({
    required String? phoneNumber,
    String? countryCode,
  }) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return null;
    }

    try {
      return fromAny(phoneNumber: phoneNumber, countryCode: countryCode);
    } on FormatException {
      return null;
    }
  }

  static PhoneNumberValue? tryFromStorageValue(String? storedValue) {
    if (storedValue == null || storedValue.trim().isEmpty) {
      return null;
    }

    final parts = storedValue.split('|');
    if (parts.length >= 2) {
      return tryFromAny(phoneNumber: parts.last, countryCode: parts.first);
    }

    return tryFromAny(phoneNumber: storedValue);
  }
}

String localPhoneDigits({
  required String dialCode,
  required String phoneNumber,
}) => PhoneNormalizer.localDigits(phoneNumber, countryCode: dialCode);

String localPhoneInputDigits({
  required String dialCode,
  required String phoneNumber,
  int? maxLocalDigits,
}) {
  final localDigits = localPhoneDigits(
    dialCode: dialCode,
    phoneNumber: phoneNumber,
  );
  if (maxLocalDigits == null || localDigits.length <= maxLocalDigits) {
    return localDigits;
  }
  return localDigits.substring(0, maxLocalDigits);
}

String normalizePhoneE164({
  required String dialCode,
  required String localNumber,
}) => PhoneNormalizer.toE164(localNumber, countryCode: dialCode);
