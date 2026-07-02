import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/utils/form_validation_mixin.dart';
import 'package:usdc_wallet/utils/form_validators.dart';

class _ValidationHarness with FormValidationMixin {}

void main() {
  group('PIN validation contract', () {
    test('FormValidators defaults to the app 6-digit PIN contract', () {
      expect(FormValidators.pin('7392'), 'PIN must be 6 digits');
      expect(FormValidators.pin('739251'), isNull);
    });

    test('FormValidationMixin defaults to the app 6-digit PIN contract', () {
      final harness = _ValidationHarness();

      expect(harness.validatePin('7392'), 'PIN must be 6 digits');
      expect(harness.validatePin('739251'), isNull);
    });
  });
}
