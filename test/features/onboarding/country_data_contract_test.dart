import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/onboarding/models/country_data.dart'
    as onboarding;
import 'package:usdc_wallet/config/countries.dart' as config;

void main() {
  group('Onboarding country data', () {
    test('uses the same enabled countries as app config', () {
      expect(
        onboarding.SupportedCountries.all.map((country) => country.code),
        config.SupportedCountries.all.map((country) => country.code),
      );
    });

    test('includes Abidjan and USA launch countries', () {
      final countries = onboarding.SupportedCountries.all;

      expect(
        countries.map((country) => country.code),
        containsAll(['CI', 'US']),
      );
      expect(onboarding.SupportedCountries.getByDialCode('+1').code, 'US');
      expect(onboarding.SupportedCountries.getByCode('CI').dialCode, '+225');
    });
  });
}
