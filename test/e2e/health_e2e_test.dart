/// E2E: Health/infrastructure endpoints — no auth required
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;

  setUpAll(() {
    client = E2EClient();
  });

  group('Health E2E', () {
    test('GET /health — API is alive', () async {
      final res = await client.get('/health');
      res.expectOk();
      expect(res.data?['status'], 'ok');
    });

    test('GET /health/time — server time', () async {
      final res = await client.get('/health/time');
      res.expectOk();
      expect(res.data?['serverTime'], isNotNull);
    });
  });

  group('Feature Flags E2E', () {
    test('GET /feature-flags — list flags (may need auth)', () async {
      final res = await client.get('/feature-flags');
      // Might need auth (401) or work publicly
      expect(res.statusCode, anyOf(200, 401, 404));
    });
  });
}
