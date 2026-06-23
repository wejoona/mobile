import 'package:usdc_wallet/config/countries.dart';

class PhoneNormalizer {
  const PhoneNormalizer._();

  static String toE164(String phone, {String? countryCode}) {
    final phoneValue = phone.contains('|') ? phone.split('|').last : phone;
    final compact = phoneValue.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (compact.startsWith('+')) {
      final digits = compact.substring(1).replaceAll(RegExp(r'\D'), '');
      final country =
          countryFromCode(countryCode) ??
          SupportedCountries.findByPhone(digits);
      return _validateE164Digits(
        _stripRepeatedCountryPrefix(digits, country),
        expectedCountry: country,
      );
    }

    final digits = compact.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00') && digits.length > 2) {
      final internationalDigits = digits.substring(2);
      final country =
          countryFromCode(countryCode) ??
          SupportedCountries.findByPhone(internationalDigits);
      return _validateE164Digits(
        _stripRepeatedCountryPrefix(internationalDigits, country),
        expectedCountry: country,
      );
    }

    final country =
        countryFromCode(countryCode) ??
        SupportedCountries.findByPhone(digits) ??
        SupportedCountries.defaultCountry;
    final normalizedDigits = _stripRepeatedCountryPrefix(digits, country);

    if (normalizedDigits.startsWith(country.prefix) &&
        normalizedDigits.length ==
            country.prefix.length + country.phoneLength) {
      return _validateE164Digits(normalizedDigits, expectedCountry: country);
    }

    if (!country.isValidLength(normalizedDigits)) {
      throw FormatException(
        'Invalid ${country.code} phone number length: ${normalizedDigits.length}',
      );
    }

    return _validateE164Digits(
      '${country.prefix}$normalizedDigits',
      expectedCountry: country,
    );
  }

  static String localDigits(String phone, {required String countryCode}) {
    final country = countryFromCode(countryCode);
    final phoneValue = phone.contains('|') ? phone.split('|').last : phone;
    if (country == null) {
      return phoneValue.replaceAll(RegExp(r'\D'), '');
    }

    try {
      final e164 = toE164(phoneValue, countryCode: country.code);
      return e164.substring(country.fullPrefix.length);
    } on FormatException {
      var digits = phoneValue.replaceAll(RegExp(r'\D'), '');
      while (digits.startsWith(country.prefix) &&
          digits.length > country.phoneLength) {
        digits = digits.substring(country.prefix.length);
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

  static String _stripRepeatedCountryPrefix(
    String digits,
    CountryConfig? country,
  ) {
    if (country == null || country.prefix.isEmpty) {
      return digits;
    }

    final expectedE164Length = country.prefix.length + country.phoneLength;
    var normalized = digits;
    while (normalized.startsWith('${country.prefix}${country.prefix}') &&
        normalized.length > expectedE164Length) {
      normalized = normalized.substring(country.prefix.length);
    }

    return normalized;
  }
}
