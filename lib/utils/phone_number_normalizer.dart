import 'package:usdc_wallet/utils/phone_normalizer.dart';

String digitsOnly(String value) => value.replaceAll(RegExp(r'\D'), '');

/// Canonical phone identity used inside the app.
///
/// Keep every common representation together so views, storage, and API
/// callers do not rebuild phone strings differently.
class PhoneNumberValue {
  const PhoneNumberValue._({
    required this.dialCode,
    required this.countryPrefix,
    required this.localNumber,
    required this.nationalNumber,
    required this.msisdn,
    required this.e164,
    required this.isoCountryCode,
    required this.displayLocal,
    required this.displayInternational,
  });

  factory PhoneNumberValue.fromLocal({
    required String dialCode,
    required String localNumber,
  }) =>
      PhoneNumberValue.fromAny(phoneNumber: localNumber, countryCode: dialCode);

  factory PhoneNumberValue.fromAny({
    required String phoneNumber,
    String? countryCode,
  }) {
    final e164 = PhoneNormalizer.toE164(phoneNumber, countryCode: countryCode);
    final msisdn = digitsOnly(e164);
    final country =
        PhoneNormalizer.countryFromCode(countryCode) ??
        PhoneNormalizer.countryFromCode(
          PhoneNormalizer.toIsoCountryCode(countryCode ?? '', e164),
        ) ??
        PhoneNormalizer.countryFromCode(msisdn);
    final dialCode = country?.fullPrefix ?? _dialCodeFromInput(countryCode);
    final countryPrefix = dialCode.replaceFirst('+', '');
    final localNumber = country == null
        ? PhoneNormalizer.localDigits(e164, countryCode: dialCode)
        : msisdn.substring(country.prefix.length);
    final displayLocal = country?.formatPhone(localNumber) ?? localNumber;

    return PhoneNumberValue._(
      dialCode: dialCode,
      countryPrefix: countryPrefix,
      localNumber: localNumber,
      nationalNumber: localNumber,
      msisdn: msisdn,
      e164: e164,
      isoCountryCode:
          country?.code ??
          PhoneNormalizer.toIsoCountryCode(countryCode ?? dialCode, e164),
      displayLocal: displayLocal,
      displayInternational: '$dialCode $displayLocal',
    );
  }

  /// Prefix with plus, for example `+225`.
  final String dialCode;

  /// Prefix without plus, for example `225`.
  final String countryPrefix;

  /// Number without country prefix. Kept as the UI-editable local value.
  final String localNumber;

  /// Alias for standards vocabulary: national significant number.
  final String nationalNumber;

  /// Digits-only international number. Equivalent to E.164 without `+`.
  final String msisdn;

  /// Full E.164 phone number, for example `+2250748805663`.
  final String e164;

  /// ISO 3166-1 alpha-2 country code, for example `CI`.
  final String isoCountryCode;

  /// Human-readable local form using the country's configured spacing.
  final String displayLocal;

  /// Human-readable international form.
  final String displayInternational;

  String get countryCode => isoCountryCode;
  String get callingCode => countryPrefix;
  String get internationalDigits => msisdn;
  String get nationalSignificantNumber => nationalNumber;
  String get apiPhone => e164;
  String get apiCountryCode => isoCountryCode;
  String get storageValue => '$isoCountryCode|$dialCode|$localNumber|$e164';

  static PhoneNumberValue? tryFromAny({
    required String? phoneNumber,
    String? countryCode,
  }) {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      return null;
    }

    try {
      return PhoneNumberValue.fromAny(
        phoneNumber: phoneNumber,
        countryCode: countryCode,
      );
    } on FormatException {
      return null;
    }
  }

  static PhoneNumberValue? tryFromStorageValue(String? storedValue) {
    if (storedValue == null || storedValue.trim().isEmpty) {
      return null;
    }

    final parts = storedValue.split('|');
    if (parts.length >= 4) {
      return tryFromAny(phoneNumber: parts[3], countryCode: parts[0]);
    }
    if (parts.length == 2) {
      return tryFromAny(phoneNumber: parts[1], countryCode: parts[0]);
    }

    return tryFromAny(phoneNumber: storedValue);
  }

  static String _dialCodeFromInput(String? countryCode) {
    final country = PhoneNormalizer.countryFromCode(countryCode);
    if (country != null) {
      return country.fullPrefix;
    }

    final digits = digitsOnly(countryCode ?? '');
    if (digits.isEmpty) {
      return '+${PhoneNormalizer.countryFromCode('CI')?.prefix ?? '225'}';
    }
    return '+$digits';
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

/// Digit extraction for fields where the country code is displayed outside
/// the editable value. Partial local input must stay untouched while typing;
/// canonical phone normalization belongs at submit/API boundaries.
String editableLocalPhoneInputDigits({
  required String dialCode,
  required String phoneNumber,
  int? maxLocalDigits,
}) {
  final raw = phoneNumber.trim();
  final digits = digitsOnly(raw);
  final dialDigits = digitsOnly(dialCode);
  final looksInternational =
      raw.contains('|') ||
      raw.startsWith('+') ||
      digits.startsWith('00') ||
      (maxLocalDigits != null &&
          dialDigits.isNotEmpty &&
          digits.startsWith(dialDigits) &&
          digits.length > maxLocalDigits);

  final localDigits = looksInternational
      ? localPhoneDigits(dialCode: dialCode, phoneNumber: raw)
      : digits;

  if (maxLocalDigits == null || localDigits.length <= maxLocalDigits) {
    return localDigits;
  }
  return localDigits.substring(0, maxLocalDigits);
}

String normalizePhoneE164({
  required String dialCode,
  required String localNumber,
}) => PhoneNormalizer.toE164(localNumber, countryCode: dialCode);
