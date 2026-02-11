/// E2E: Bill Payments — providers, validate, pay, history
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  const testPhone = '+2250700000000';

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(testPhone);
  });

  group('Bill Payments E2E', () {
    test('GET /bill-payments/providers — list providers', () async {
      final res = await client.get('/bill-payments/providers');
      res.expectOk();
    });

    test('GET /bill-payments/categories — list categories', () async {
      final res = await client.get('/bill-payments/categories');
      res.expectOk();
    });

    test('GET /bill-payments/history — payment history', () async {
      final res = await client.get('/bill-payments/history');
      res.expectOk();
    });

    test('POST /bill-payments/validate — validate bill reference', () async {
      final res = await client.post('/bill-payments/validate', {
        'providerId': 'cie',
        'reference': 'REF-12345',
      });
      // 200 if valid, 400/404 if provider not found
      expect(res.statusCode, anyOf(200, 400, 404));
    });

    test('POST /bill-payments/pay — missing fields returns 400', () async {
      final res = await client.post('/bill-payments/pay', {});
      expect(res.statusCode, 400);
    });

    test('POST /bill-payments/pay — invalid provider returns 400/404', () async {
      final res = await client.post('/bill-payments/pay', {
        'providerId': 'nonexistent',
        'reference': 'REF-12345',
        'amount': 5000,
      });
      expect(res.statusCode, anyOf(400, 404));
    });

    test('GET /bill-payments/providers — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/bill-payments/providers');
      expect(res.statusCode, 401);
    });
  });
}
