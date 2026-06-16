import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/security/certificate_pinning_config.dart';

void main() {
  group('CertificatePinRegistry', () {
    const apiLeafSpki = 'DcXImxqsw11wXDKaem3Be3mcFibKSosQGkPpNOw9Zuw=';
    const apexLeafSpki = 'vz/Oj4HDd7i5iGnOiGk+BAZa/i62MKNdA74TWH/6pew=';
    const gtsWe1Spki = 'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=';

    test('keeps separate production leaf pins for API and apex hosts', () {
      final productionPins = CertificatePinRegistry.getPins(isProduction: true);

      final apiPins = productionPins.singleWhere(
        (config) => config.host == 'korido-api.joonapay.com',
      );
      final apexPins = productionPins.singleWhere(
        (config) => config.host == 'joonapay.com',
      );

      expect(apiPins.sha256Pins, containsAll([apiLeafSpki, gtsWe1Spki]));
      expect(apiPins.sha256Pins, isNot(contains(apexLeafSpki)));
      expect(apexPins.sha256Pins, containsAll([apexLeafSpki, gtsWe1Spki]));
      expect(apexPins.sha256Pins, isNot(contains(apiLeafSpki)));
    });

    test('validates host-specific leaf pins and shared backup pin', () {
      expect(
        CertificatePinRegistry.validatePin(
          'korido-api.joonapay.com',
          apiLeafSpki,
          isProduction: true,
        ),
        isTrue,
      );
      expect(
        CertificatePinRegistry.validatePin(
          'joonapay.com',
          apexLeafSpki,
          isProduction: true,
        ),
        isTrue,
      );
      expect(
        CertificatePinRegistry.validatePin(
          'korido-api.joonapay.com',
          gtsWe1Spki,
          isProduction: true,
        ),
        isTrue,
      );
      expect(
        CertificatePinRegistry.validatePin(
          'korido-api.joonapay.com',
          apexLeafSpki,
          isProduction: true,
        ),
        isFalse,
      );
    });

    test('does not keep placeholder staging pins', () {
      final stagingPins = CertificatePinRegistry.getPins(isProduction: false);

      expect(stagingPins, isEmpty);
      expect(
        CertificatePinRegistry.validatePin(
          'staging-korido-api.joonapay.com',
          'unconfigured-pin',
          isProduction: false,
        ),
        isTrue,
      );
    });
  });
}
