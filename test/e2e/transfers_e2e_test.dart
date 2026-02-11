/// E2E: Transfer endpoints — internal, external, history
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

  group('Transfers E2E', () {
    test('GET /transfers — list transfers', () async {
      final res = await client.get('/transfers');
      res.expectOk();
      // Should return array or paginated object
      expect(res.data, isNotNull);
    });

    test('POST /transfers/internal — missing recipient returns 400', () async {
      final res = await client.post('/transfers/internal', {
        'amount': 100,
      });
      expect(res.statusCode, 400);
    });

    test('POST /transfers/internal — missing amount returns 400', () async {
      final res = await client.post('/transfers/internal', {
        'recipientPhone': '+2250711111111',
      });
      expect(res.statusCode, 400);
    });

    test('POST /transfers/internal — zero amount returns 400', () async {
      final res = await client.post('/transfers/internal', {
        'recipientPhone': '+2250711111111',
        'amount': 0,
      });
      expect(res.statusCode, 400);
    });

    test('POST /transfers/internal — negative amount returns 400', () async {
      final res = await client.post('/transfers/internal', {
        'recipientPhone': '+2250711111111',
        'amount': -50,
      });
      expect(res.statusCode, 400);
    });

    test('POST /transfers/external — missing fields returns 400', () async {
      final res = await client.post('/transfers/external', {});
      expect(res.statusCode, 400);
    });

    test('GET /transfers — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/transfers');
      expect(res.statusCode, 401);
    });
  });
}
