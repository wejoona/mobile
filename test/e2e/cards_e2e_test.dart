/// E2E: Cards — list, create, freeze/unfreeze, transactions
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  String? createdCardId;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
    await client.ensureWallet();
  });

  e2eGroup('Cards E2E', () {
    test('GET /cards — list cards', () async {
      final res = await client.get('/cards');
      res.expectOk();
    });

    test('POST /cards — create virtual card', () async {
      final res = await client.post('/cards', {
        'cardholderName': 'E2E Test User',
        'spendingLimit': 250,
        'cardType': 'virtual',
      });
      expect(res.statusCode, anyOf(200, 201));
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

    test('PUT /cards/:id/freeze — freeze card', () async {
      if (createdCardId == null) return;
      final res = await client.put('/cards/$createdCardId/freeze');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('PUT /cards/:id/unfreeze — unfreeze card', () async {
      if (createdCardId == null) return;
      final res = await client.put('/cards/$createdCardId/unfreeze');
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
