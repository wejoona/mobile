import 'package:usdc_wallet/config/countries.dart';

class PhoneNormalizer {
  const PhoneNormalizer._();

  static String toE164(String phone, {String? countryCode}) {
    final compact = phone.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (compact.startsWith('+')) {
      return _validateE164Digits(
        compact.substring(1).replaceAll(RegExp(r'\D'), ''),
      );
    }

    final digits = compact.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00') && digits.length > 2) {
      return _validateE164Digits(digits.substring(2));
    }

    final country =
        countryFromCode(countryCode) ??
        SupportedCountries.findByPhone(digits) ??
        SupportedCountries.defaultCountry;

    if (digits.startsWith(country.prefix) &&
        digits.length == country.prefix.length + country.phoneLength) {
      return _validateE164Digits(digits, expectedCountry: country);
    }

    if (!country.isValidLength(digits)) {
      throw FormatException(
        'Invalid ${country.code} phone number length: ${digits.length}',
      );
    }

    return _validateE164Digits(
      '${country.prefix}$digits',
      expectedCountry: country,
    );
  }

  static String localDigits(String phone, {required String countryCode}) {
    final country = countryFromCode(countryCode);
    if (country == null) {
      return phone.replaceAll(RegExp(r'\D'), '');
    }

    try {
      final e164 = toE164(phone, countryCode: country.code);
      return e164.substring(country.fullPrefix.length);
    } on FormatException {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.startsWith(country.prefix)) {
        return digits.substring(country.prefix.length);
      }
      return digits;
    }
  }

  static String toIsoCountryCode(String countryCode, String normalizedPhone) {
    final fromCode = countryFromCode(countryCode);
    if (fromCode != null) {
      return fromCode.code;
    }

    final upper = countryCode.trim().toUpperCase();
    if (SupportedCountries.findByCodeIncludingDisabled(upper) != null) {
      return upper;
    }

    return SupportedCountries.findByPhone(normalizedPhone)?.code ??
        SupportedCountries.defaultCountry.code;
  }

  static CountryConfig? countryFromCode(String? countryCode) {
    if (countryCode == null || countryCode.trim().isEmpty) {
      return null;
    }

    final trimmed = countryCode.trim();
    if (trimmed.startsWith('+') || RegExp(r'^\d+$').hasMatch(trimmed)) {
      return SupportedCountries.findByPrefix(trimmed);
    }

    return SupportedCountries.findByCodeIncludingDisabled(
      trimmed.toUpperCase(),
    );
  }

  static String _validateE164Digits(
    String digits, {
    CountryConfig? expectedCountry,
  }) {
    if (!RegExp(r'^[1-9]\d{1,14}$').hasMatch(digits)) {
      throw const FormatException('Phone must be valid E.164');
    }

    final country = expectedCountry ?? SupportedCountries.findByPhone(digits);
    if (country != null) {
      final localDigits = digits.substring(country.prefix.length);
      if (!country.isValidLength(localDigits)) {
        throw FormatException(
          'Invalid ${country.code} phone number length: ${localDigits.length}',
        );
      }
    }

    return '+$digits';
  }
}
