/// Country data for phone input
class CountryData {
  final String name;
  final String code;
  final String dialCode;
  final String flag;
  final String phoneFormat;

  const CountryData({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    required this.phoneFormat,
  });

  String get displayName => '$flag $name ($dialCode)';
}

/// Supported West African countries
class SupportedCountries {
  static const coteDivoire = CountryData(
    name: "Côte d'Ivoire",
    code: 'CI',
    dialCode: '+225',
    flag: '🇨🇮',
    phoneFormat: 'XX XX XX XX XX',
  );

  static const senegal = CountryData(
    name: 'Senegal',
    code: 'SN',
    dialCode: '+221',
    flag: '🇸🇳',
    phoneFormat: 'XX XXX XX XX',
  );

  static const mali = CountryData(
    name: 'Mali',
    code: 'ML',
    dialCode: '+223',
    flag: '🇲🇱',
    phoneFormat: 'XX XX XX XX',
  );

  static const List<CountryData> all = [
    coteDivoire,
    senegal,
    mali,
  ];

  static CountryData getByDialCode(String dialCode) {
    return all.firstWhere(
      (country) => country.dialCode == dialCode,
      orElse: () => coteDivoire,
    );
  }
}
