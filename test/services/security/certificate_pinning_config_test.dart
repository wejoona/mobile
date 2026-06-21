import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/security/certificate_pinning_config.dart';

void main() {
  group('CertificatePinRegistry', () {
    const apiLeafSpki = 'DcXImxqsw11wXDKaem3Be3mcFibKSosQGkPpNOw9Zuw=';
    const apexLeafSpki = 'dnwFNJb53pgHXDzto90QqivYDXDUKaYHYU7OxVOxgVw=';
    const previousApexLeafSpki = 'vz/Oj4HDd7i5iGnOiGk+BAZa/i62MKNdA74TWH/6pew=';
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
      expect(
        apexPins.sha256Pins,
        containsAll([apexLeafSpki, previousApexLeafSpki, gtsWe1Spki]),
      );
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
          previousApexLeafSpki,
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

    test(
      'pins staging API explicitly without wildcard subdomain inheritance',
      () {
        final stagingPins = CertificatePinRegistry.getPins(isProduction: false);

        expect(stagingPins, hasLength(1));
        expect(stagingPins.single.host, 'staging-korido-api.joonapay.com');
        expect(stagingPins.single.includeSubdomains, isFalse);
        expect(
          stagingPins.single.sha256Pins,
          containsAll([apiLeafSpki, gtsWe1Spki]),
        );
        expect(
          CertificatePinRegistry.validatePin(
            'staging-korido-api.joonapay.com',
            apiLeafSpki,
            isProduction: false,
          ),
          isTrue,
        );
        expect(
          CertificatePinRegistry.validatePin(
            'staging-korido-api.joonapay.com',
            'wrong-pin',
            isProduction: false,
          ),
          isFalse,
        );
        expect(
          CertificatePinRegistry.validatePin(
            'api.joonapay.com',
            'wrong-pin',
            isProduction: false,
          ),
          isTrue,
          reason: 'Unconfigured hosts fall back to normal platform TLS.',
        );
        expect(
          CertificatePinRegistry.validatePin(
            'sub.staging-korido-api.joonapay.com',
            'wrong-pin',
            isProduction: false,
          ),
          isTrue,
          reason: 'Subdomains are not pinned when includeSubdomains is false.',
        );
      },
    );
  });
}
