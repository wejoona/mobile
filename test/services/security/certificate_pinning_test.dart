import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/security/certificate_pinning.dart';

void main() {
  group('CertificatePinning', () {
    test('is configured with real production pins', () {
      expect(CertificatePinning.isConfigured(), isTrue);
    });

    test('matches production hosts and subdomains only', () {
      expect(
        CertificatePinning.hostRequiresPinning('api.joonapay.com'),
        isTrue,
      );
      expect(CertificatePinning.hostRequiresPinning('joonapay.com'), isTrue);
      expect(
        CertificatePinning.hostRequiresPinning('mobile.api.joonapay.com'),
        isTrue,
      );
      expect(
        CertificatePinning.hostRequiresPinning('api.example.com'),
        isFalse,
      );
    });

    test('configures Dio with post-handshake certificate validation', () {
      final dio = Dio();

      CertificatePinning.configurePinning(dio, forceForTesting: true);

      final adapter = dio.httpClientAdapter;
      expect(adapter, isA<IOHttpClientAdapter>());
      expect((adapter as IOHttpClientAdapter).validateCertificate, isNotNull);
    });
  });
}
