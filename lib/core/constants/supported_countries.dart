/// Supported countries for Korido in West Africa.
library;

class SupportedCountry {
  final String code;
  final String name;
  final String dialCode;
  final String flag;
  final String currency;
  final int phoneLength;

  const SupportedCountry({
    required this.code,
    required this.name,
    required this.dialCode,
    required this.flag,
    required this.currency,
    required this.phoneLength,
  });
}

abstract final class SupportedCountries {
  static const List<SupportedCountry> all = [
    SupportedCountry(code: 'CI', name: 'Ivory Coast', dialCode: '+225', flag: 'CI', currency: 'XOF', phoneLength: 10),
    SupportedCountry(code: 'SN', name: 'Senegal', dialCode: '+221', flag: 'SN', currency: 'XOF', phoneLength: 9),
    SupportedCountry(code: 'ML', name: 'Mali', dialCode: '+223', flag: 'ML', currency: 'XOF', phoneLength: 8),
    SupportedCountry(code: 'BF', name: 'Burkina Faso', dialCode: '+226', flag: 'BF', currency: 'XOF', phoneLength: 8),
    SupportedCountry(code: 'GN', name: 'Guinea', dialCode: '+224', flag: 'GN', currency: 'GNF', phoneLength: 9),
    SupportedCountry(code: 'BJ', name: 'Benin', dialCode: '+229', flag: 'BJ', currency: 'XOF', phoneLength: 8),
    SupportedCountry(code: 'TG', name: 'Togo', dialCode: '+228', flag: 'TG', currency: 'XOF', phoneLength: 8),
    SupportedCountry(code: 'NE', name: 'Niger', dialCode: '+227', flag: 'NE', currency: 'XOF', phoneLength: 8),
    SupportedCountry(code: 'GH', name: 'Ghana', dialCode: '+233', flag: 'GH', currency: 'GHS', phoneLength: 9),
    SupportedCountry(code: 'NG', name: 'Nigeria', dialCode: '+234', flag: 'NG', currency: 'NGN', phoneLength: 10),
    SupportedCountry(code: 'CM', name: 'Cameroon', dialCode: '+237', flag: 'CM', currency: 'XAF', phoneLength: 9),
  ];

  static SupportedCountry? byCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }

  static SupportedCountry? byDialCode(String dialCode) {
    try {
      return all.firstWhere((c) => c.dialCode == dialCode);
    } catch (_) {
      return null;
    }
  }

  /// Default country (Ivory Coast).
  static const SupportedCountry defaultCountry = SupportedCountry(
    code: 'CI',
    name: 'Ivory Coast',
    dialCode: '+225',
    flag: 'CI',
    currency: 'XOF',
    phoneLength: 10,
  );
}
