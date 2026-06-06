import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('security exports', () {
    test('use the platform-channel device attestation implementation', () {
      final authBarrel = File(
        'lib/services/security/auth/index.dart',
      ).readAsStringSync();
      final securityBarrel = File(
        'lib/services/security/index.dart',
      ).readAsStringSync();
      final platformAttestation = File(
        'lib/services/security/device_attestation.dart',
      ).readAsStringSync();

      expect(authBarrel, isNot(contains('device_attestation_service.dart')));
      expect(
        securityBarrel,
        contains('services/security/device_attestation.dart'),
      );
      expect(
        platformAttestation,
        contains("MethodChannel('com.joonapay.usdc_wallet/attestation')"),
      );
      expect(
        Directory('lib/services/security/auth')
            .listSync()
            .whereType<File>()
            .map((file) => file.path)
            .where((path) => path.endsWith('device_attestation_service.dart')),
        isEmpty,
      );
    });
  });
}
