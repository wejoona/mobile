import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/config/countries.dart';
import 'package:usdc_wallet/utils/phone_hints.dart';

void main() {
  group('phoneHintForCountry', () {
    test('uses country dial code and format pattern', () {
      const country = CountryConfig(
        code: 'CI',
        name: "Côte d'Ivoire",
        prefix: '225',
        phoneLength: 10,
        flag: '🇨🇮',
        currencies: ['XOF'],
        phoneFormat: 'XX XX XX XX XX',
        isEnabled: true,
      );

      expect(phoneHintForCountry(country), '+225 XX XX XX XX XX');
    });

    test('falls back to generic format when pattern missing', () {
      const country = CountryConfig(
        code: 'SN',
        name: 'Sénégal',
        prefix: '221',
        phoneLength: 9,
        flag: '🇸🇳',
        currencies: ['XOF'],
        isEnabled: true,
      );

      expect(phoneHintForCountry(country), '+221 XX XX XX XX XX');
    });
  });
}