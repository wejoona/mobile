/// E2E: Cards — list, create, freeze/unfreeze, transactions
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  const testPhone = '+2250700000000';
  String? createdCardId;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(testPhone);
  });

  group('Cards E2E', () {
    test('GET /cards — list cards', () async {
      final res = await client.get('/cards');
      res.expectOk();
    });

    test('POST /cards — create virtual card', () async {
      final res = await client.post('/cards', {
        'type': 'virtual',
        'currency': 'USD',
        'label': 'E2E Test Card',
      });
      // 201 created, 200, or 400 if not eligible
      expect(res.statusCode, anyOf(200, 201, 400, 403));
      if (res.isOk) {
        final data = res.data?['data'] ?? res.data;
        createdCardId = data?['id']?.toString();
      }
    });

    test('GET /cards/:id — get card details', () async {
      if (createdCardId == null) return;
      final res = await client.get('/cards/$createdCardId');
      res.expectOk();
    });

    test('POST /cards/:id/freeze — freeze card', () async {
      if (createdCardId == null) return;
      final res = await client.post('/cards/$createdCardId/freeze');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('POST /cards/:id/unfreeze — unfreeze card', () async {
      if (createdCardId == null) return;
      final res = await client.post('/cards/$createdCardId/unfreeze');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('GET /cards/:id/transactions — card transactions', () async {
      if (createdCardId == null) return;
      final res = await client.get('/cards/$createdCardId/transactions');
      res.expectOk();
    });

    test('GET /cards — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/cards');
      expect(res.statusCode, 401);
    });
  });
}
