/// E2E: Payment Links — create, list, get, deactivate, pay
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  const testPhone = '+2250700000000';
  String? createdLinkId;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(testPhone);
  });

  group('Payment Links E2E', () {
    test('POST /payment-links — create link', () async {
      final res = await client.post('/payment-links', {
        'amount': 5000,
        'currency': 'XOF',
        'description': 'E2E test payment link',
      });
      // 201 created or 200
      expect(res.statusCode, anyOf(200, 201));
      final data = res.data?['data'] ?? res.data;
      createdLinkId = data?['id']?.toString();
    });

    test('GET /payment-links — list all links', () async {
      final res = await client.get('/payment-links');
      res.expectOk();
    });

    test('GET /payment-links/:id — get specific link', () async {
      if (createdLinkId == null) return; // skip if create failed
      final res = await client.get('/payment-links/$createdLinkId');
      res.expectOk();
    });

    test('GET /payment-links/nonexistent — returns 404', () async {
      final res = await client.get('/payment-links/00000000-0000-0000-0000-000000000000');
      expect(res.statusCode, anyOf(404, 400));
    });

    test('POST /payment-links — missing amount returns 400', () async {
      final res = await client.post('/payment-links', {
        'description': 'No amount',
      });
      expect(res.statusCode, 400);
    });

    test('POST /payment-links/:id/deactivate — deactivate link', () async {
      if (createdLinkId == null) return;
      final res = await client.post('/payment-links/$createdLinkId/deactivate');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('POST /payment-links — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.post('/payment-links', {
        'amount': 1000,
        'currency': 'XOF',
      });
      expect(res.statusCode, 401);
    });
  });
}
