/// Country configuration for phone validation and currency support
/// Each country defines its phone format and supported currencies

class CountryConfig {
  final String code;        // ISO 3166-1 alpha-2 (e.g., 'CI')
  final String name;        // Display name
  final String prefix;      // Phone prefix without + (e.g., '225')
  final int phoneLength;    // Total digits AFTER prefix (e.g., 10 for Ivory Coast)
  final String flag;        // Flag emoji
  final List<String> currencies;  // Supported local currencies
  final String? phoneFormat; // Optional format hint (e.g., 'XX XX XX XX XX')
  final bool isEnabled;     // Whether this country is currently enabled

  const CountryConfig({
    required this.code,
    required this.name,
    required this.prefix,
    required this.phoneLength,
    required this.flag,
    required this.currencies,
    this.phoneFormat,
    this.isEnabled = false,  // Disabled by default
  });

  /// Full prefix with +
  String get fullPrefix => '+$prefix';

  /// Validate phone number length (digits only, without prefix)
  bool isValidLength(String phoneDigits) {
    return phoneDigits.length == phoneLength;
  }

  /// Format phone number for display
  String formatPhone(String digits) {
    if (phoneFormat == null || digits.length != phoneLength) {
      return digits;
    }

    // Apply format pattern (X = digit placeholder)
    var result = StringBuffer();
    var digitIndex = 0;
    for (var char in phoneFormat!.split('')) {
      if (char == 'X' && digitIndex < digits.length) {
        result.write(digits[digitIndex]);
        digitIndex++;
      } else if (char != 'X') {
        result.write(char);
      }
    }
    return result.toString();
  }
}

/// Supported countries for JoonaPay
/// Focus on West/Central Africa with mobile money infrastructure
class SupportedCountries {
  /// All countries (including disabled ones for future expansion)
  static const List<CountryConfig> _allCountries = [
    // ═══════════════════════════════════════════════════════════════════════════
    // ENABLED COUNTRIES (Phase 1 Launch)
    // ═══════════════════════════════════════════════════════════════════════════

    // United States
    CountryConfig(
      code: 'US',
      name: 'United States',
      prefix: '1',
      phoneLength: 10,
      flag: '\u{1F1FA}\u{1F1F8}',
      currencies: ['USD'],
      phoneFormat: 'XXX XXX XXXX',
      isEnabled: true,
    ),

    // Ivory Coast (Primary African Market)
    CountryConfig(
      code: 'CI',
      name: "Côte d'Ivoire",
      prefix: '225',
      phoneLength: 10,
      flag: '\u{1F1E8}\u{1F1EE}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XX XX XX XX XX',
      isEnabled: true,
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // COMING SOON - West Africa CFA Franc Zone (XOF)
    // ═══════════════════════════════════════════════════════════════════════════

    CountryConfig(
      code: 'SN',
      name: 'Senegal',
      prefix: '221',
      phoneLength: 9,
      flag: '\u{1F1F8}\u{1F1F3}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XX XXX XX XX',
    ),
    CountryConfig(
      code: 'ML',
      name: 'Mali',
      prefix: '223',
      phoneLength: 8,
      flag: '\u{1F1F2}\u{1F1F1}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XX XX XX XX',
    ),
    CountryConfig(
      code: 'BF',
      name: 'Burkina Faso',
      prefix: '226',
      phoneLength: 8,
      flag: '\u{1F1E7}\u{1F1EB}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XX XX XX XX',
    ),
    CountryConfig(
      code: 'BJ',
      name: 'Benin',
      prefix: '229',
      phoneLength: 8,
      flag: '\u{1F1E7}\u{1F1EF}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XX XX XX XX',
    ),
    CountryConfig(
      code: 'TG',
      name: 'Togo',
      prefix: '228',
      phoneLength: 8,
      flag: '\u{1F1F9}\u{1F1EC}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XX XX XX XX',
    ),
    CountryConfig(
      code: 'NE',
      name: 'Niger',
      prefix: '227',
      phoneLength: 8,
      flag: '\u{1F1F3}\u{1F1EA}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XX XX XX XX',
    ),
    CountryConfig(
      code: 'GW',
      name: 'Guinea-Bissau',
      prefix: '245',
      phoneLength: 7,
      flag: '\u{1F1EC}\u{1F1FC}',
      currencies: ['XOF', 'USD'],
      phoneFormat: 'XXX XX XX',
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // COMING SOON - Central Africa CFA Franc Zone (XAF)
    // ═══════════════════════════════════════════════════════════════════════════

    CountryConfig(
      code: 'CM',
      name: 'Cameroon',
      prefix: '237',
      phoneLength: 9,
      flag: '\u{1F1E8}\u{1F1F2}',
      currencies: ['XAF', 'USD'],
      phoneFormat: 'X XX XX XX XX',
    ),
    CountryConfig(
      code: 'GA',
      name: 'Gabon',
      prefix: '241',
      phoneLength: 8,
      flag: '\u{1F1EC}\u{1F1E6}',
      currencies: ['XAF', 'USD'],
      phoneFormat: 'XX XX XX XX',
    ),
    CountryConfig(
      code: 'CG',
      name: 'Congo',
      prefix: '242',
      phoneLength: 9,
      flag: '\u{1F1E8}\u{1F1EC}',
      currencies: ['XAF', 'USD'],
      phoneFormat: 'XX XXX XXXX',
    ),

    // ═══════════════════════════════════════════════════════════════════════════
    // COMING SOON - Other African Countries
    // ═══════════════════════════════════════════════════════════════════════════

    CountryConfig(
      code: 'GH',
      name: 'Ghana',
      prefix: '233',
      phoneLength: 9,
      flag: '\u{1F1EC}\u{1F1ED}',
      currencies: ['GHS', 'USD'],
      phoneFormat: 'XX XXX XXXX',
    ),
    CountryConfig(
      code: 'NG',
      name: 'Nigeria',
      prefix: '234',
      phoneLength: 10,
      flag: '\u{1F1F3}\u{1F1EC}',
      currencies: ['NGN', 'USD'],
      phoneFormat: 'XXX XXX XXXX',
    ),
    // Kenya removed — not a target market
    CountryConfig(
      code: 'TZ',
      name: 'Tanzania',
      prefix: '255',
      phoneLength: 9,
      flag: '\u{1F1F9}\u{1F1FF}',
      currencies: ['TZS', 'USD'],
      phoneFormat: 'XXX XXX XXX',
    ),
    CountryConfig(
      code: 'UG',
      name: 'Uganda',
      prefix: '256',
      phoneLength: 9,
      flag: '\u{1F1FA}\u{1F1EC}',
      currencies: ['UGX', 'USD'],
      phoneFormat: 'XXX XXX XXX',
    ),
    CountryConfig(
      code: 'RW',
      name: 'Rwanda',
      prefix: '250',
      phoneLength: 9,
      flag: '\u{1F1F7}\u{1F1FC}',
      currencies: ['RWF', 'USD'],
      phoneFormat: 'XXX XXX XXX',
    ),
    CountryConfig(
      code: 'ZA',
      name: 'South Africa',
      prefix: '27',
      phoneLength: 9,
      flag: '\u{1F1FF}\u{1F1E6}',
      currencies: ['ZAR', 'USD'],
      phoneFormat: 'XX XXX XXXX',
    ),
  ];

  /// Only enabled countries (for production use)
  static List<CountryConfig> get all =>
      _allCountries.where((c) => c.isEnabled).toList();

  /// All countries including disabled (for admin/debug)
  static List<CountryConfig> get allIncludingDisabled => _allCountries;

  /// Default country (Ivory Coast - primary African market)
  static CountryConfig get defaultCountry => all.firstWhere(
        (c) => c.code == 'CI',
        orElse: () => all.first,
      );

  /// Find country by ISO code (only enabled countries)
  static CountryConfig? findByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find country by ISO code (including disabled)
  static CountryConfig? findByCodeIncludingDisabled(String code) {
    try {
      return _allCountries.firstWhere((c) => c.code == code);
    } catch (_) {
      return null;
    }
  }

  /// Find country by phone prefix (only enabled)
  static CountryConfig? findByPrefix(String prefix) {
    final cleanPrefix = prefix.startsWith('+') ? prefix.substring(1) : prefix;
    try {
      return all.firstWhere((c) => c.prefix == cleanPrefix);
    } catch (_) {
      return null;
    }
  }

  /// Find country from full phone number (only enabled)
  static CountryConfig? findByPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    for (final country in all) {
      if (cleanPhone.startsWith(country.prefix)) {
        return country;
      }
    }
    return null;
  }

  /// Check if a country is enabled
  static bool isCountryEnabled(String code) {
    return all.any((c) => c.code == code);
  }
}
