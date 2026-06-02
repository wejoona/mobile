import 'package:usdc_wallet/config/countries.dart';

class PhoneNormalizer {
  const PhoneNormalizer._();

  static String toE164(String phone, {String? countryCode}) {
    final compact = phone.trim().replaceAll(RegExp(r'[\s\-().]'), '');
    if (compact.startsWith('+')) {
      return '+${compact.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }

    final digits = compact.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00') && digits.length > 2) {
      return '+${digits.substring(2)}';
    }

    final country =
        countryFromCode(countryCode) ??
        SupportedCountries.findByPhone(digits) ??
        SupportedCountries.defaultCountry;

    if (digits.startsWith(country.prefix) &&
        digits.length == country.prefix.length + country.phoneLength) {
      return '+$digits';
    }

    return '+${country.prefix}$digits';
  }

  static String toIsoCountryCode(String countryCode, String normalizedPhone) {
    final fromCode = countryFromCode(countryCode);
    if (fromCode != null) return fromCode.code;

    final upper = countryCode.trim().toUpperCase();
    if (SupportedCountries.findByCodeIncludingDisabled(upper) != null) {
      return upper;
    }

    return SupportedCountries.findByPhone(normalizedPhone)?.code ??
        SupportedCountries.defaultCountry.code;
  }

  static CountryConfig? countryFromCode(String? countryCode) {
    if (countryCode == null || countryCode.trim().isEmpty) return null;

    final trimmed = countryCode.trim();
    if (trimmed.startsWith('+') || RegExp(r'^\d+$').hasMatch(trimmed)) {
      return SupportedCountries.findByPrefix(trimmed);
    }

    return SupportedCountries.findByCodeIncludingDisabled(
      trimmed.toUpperCase(),
    );
  }
}
