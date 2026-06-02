import 'package:usdc_wallet/config/countries.dart' as app_config;

/// Country data for onboarding phone input.
///
/// This wraps the shared app country config so login and registration expose
/// the same launch markets.
class CountryData {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  final String phoneFormat;
  final int phoneLength;

  const CountryData({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.phoneFormat,
    required this.phoneLength,
  });

  factory CountryData.fromConfig(app_config.CountryConfig country) {
    return CountryData(
      name: country.name,
      code: country.code,
      dialCode: country.fullPrefix,
      flag: country.flag,
      phoneFormat:
          country.phoneFormat ?? List.filled(country.phoneLength, 'X').join(),
      phoneLength: country.phoneLength,
    );
  }

  String get displayName => '$flag $name ($dialCode)';
}

class SupportedCountries {
  static final List<CountryData> all = app_config.SupportedCountries.all
      .map(CountryData.fromConfig)
      .toList(growable: false);

  static final CountryData coteDivoire = getByCode('CI');

  static CountryData getByDialCode(String dialCode) {
    return all.firstWhere(
      (country) => country.dialCode == dialCode,
      orElse: () => coteDivoire,
    );
  }

  static CountryData getByCode(String code) {
    return all.firstWhere(
      (country) => country.code == code,
      orElse: () =>
          CountryData.fromConfig(app_config.SupportedCountries.defaultCountry),
    );
  }
}
