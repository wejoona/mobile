import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/utils/input_formatters.dart';

void main() {
  group('LocalPhoneInputFormatter', () {
    test('strips selected dial code from pasted international number', () {
      final formatter = LocalPhoneInputFormatter(
        dialCode: '+225',
        maxLocalDigits: 10,
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '+2250748805663'),
      );

      expect(result.text, '0748805663');
    });

    test('formats local signup number without duplicating dial code', () {
      final formatter = LocalPhoneInputFormatter(
        dialCode: '+225',
        maxLocalDigits: 10,
        displayFormat: 'XX XX XX XX XX',
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '+2250748805663'),
      );

      expect(result.text, '07 48 80 56 63');
    });

    test('keeps local number as local number', () {
      final formatter = LocalPhoneInputFormatter(
        dialCode: '+225',
        maxLocalDigits: 10,
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '0748805663'),
      );

      expect(result.text, '0748805663');
    });
  });
}
