import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/features/settings/utils/profile_phone_formatter.dart';

void main() {
  group('formatProfilePhone', () {
    test('formats Ivory Coast and US phones from country metadata', () {
      expect(formatProfilePhone('+2250748805663'), '+225 07 48 80 56 63');
      expect(formatProfilePhone('+14155550101'), '+1 415 555 0101');
    });

    test('keeps unknown or empty values stable', () {
      expect(formatProfilePhone(null), '');
      expect(formatProfilePhone(''), '');
      expect(formatProfilePhone('not-a-phone'), 'not-a-phone');
    });
  });
}
