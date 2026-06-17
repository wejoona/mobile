import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/auth/models/login_state.dart';
import 'package:usdc_wallet/utils/phone_normalizer.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

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

    test('repairs duplicated country code input at the value boundary', () {
      expect(
        PhoneNormalizer.toE164('+225+2250748805663', countryCode: '+225'),
        '+2250748805663',
      );
      expect(
        PhoneNormalizer.toE164('2252250748805663', countryCode: 'CI'),
        '+2250748805663',
      );
    });

    test('does not duplicate dial code when composing E.164', () {
      expect(
        normalizePhoneE164(dialCode: '+225', localNumber: '+2250748805663'),
        '+2250748805663',
      );
    });

    test('normalizes US local numbers with explicit country', () {
      expect(
        PhoneNormalizer.toE164('(415) 555-0101', countryCode: 'US'),
        '+14155550101',
      );
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

    test(
      'recovers legacy remembered phone values without duplicating prefix',
      () {
        final value = PhoneNumberValue.fromAny(
          phoneNumber: '+225|+2250748805663',
          countryCode: '+225',
        );

        expect(value.dialCode, '+225');
        expect(value.localNumber, '0748805663');
        expect(value.e164, '+2250748805663');
        expect(value.storageValue, '+225|0748805663');
        expect(
          localPhoneDigits(
            dialCode: '+225',
            phoneNumber: '+225|+2250748805663',
          ),
          '0748805663',
        );
      },
    );

    test('parses remembered phone storage as dial code plus local digits', () {
      final stored = PhoneNumberValue.tryFromStorageValue(
        '+225|+2250748805663',
      );
      final legacy = PhoneNumberValue.tryFromStorageValue('+14155550101');

      expect(stored?.dialCode, '+225');
      expect(stored?.localNumber, '0748805663');
      expect(stored?.storageValue, '+225|0748805663');
      expect(legacy?.dialCode, '+1');
      expect(legacy?.localNumber, '4155550101');
    });

    test('keeps login form state explicit about dial codes', () {
      const state = LoginState(phoneNumber: '4155550101', dialCode: '+1');
      const request = LoginRequest(phoneNumber: '4155550101', dialCode: '+1');

      expect(state.dialCode, '+1');
      expect(request.toJson(), {'phoneNumber': '4155550101', 'dialCode': '+1'});
    });
  });
}
