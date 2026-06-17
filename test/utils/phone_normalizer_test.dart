import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';
import 'package:usdc_wallet/utils/phone_normalizer.dart';

void main() {
  group('PhoneNormalizer', () {
    test('normalizes local Ivory Coast phone numbers to E.164', () {
      expect(
        PhoneNormalizer.toE164('07 00 00 00 00', countryCode: 'CI'),
        '+2250700000000',
      );
    });

    test('keeps already international phone numbers in E.164', () {
      expect(PhoneNormalizer.toE164('+225 07 00 00 00 00'), '+2250700000000');
    });

    test('maps dial-code country values to ISO codes', () {
      expect(PhoneNormalizer.toIsoCountryCode('+225', '+2250700000000'), 'CI');
    });

    test('extracts the same local identity from local and E.164 numbers', () {
      expect(
        localPhoneDigits(dialCode: '+225', phoneNumber: '+2250748805663'),
        '0748805663',
      );
      expect(
        localPhoneDigits(dialCode: '+225', phoneNumber: '0748805663'),
        '0748805663',
      );
    });
  });
}
