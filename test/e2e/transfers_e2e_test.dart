/// E2E: Wallet transfer endpoints — internal, external, history
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }

  late E2EClient client;

  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
  });

  e2eGroup('Wallet Transfers E2E', () {
    test('GET /wallet/transactions — list money history', () async {
      final res = await client.get('/wallet/transactions');
      res.expectOk();
      // Should return array or paginated object
      expect(res.data, isNotNull);
    });

    test(
      'POST /wallet/transfer/internal — missing recipient returns 400',
      () async {
        final res = await client.post('/wallet/transfer/internal', {
          'amount': 100,
        });
        expect(res.statusCode, 400);
      },
    );

    test(
      'POST /wallet/transfer/internal — missing amount returns 400',
      () async {
        final res = await client.post('/wallet/transfer/internal', {
          'recipientPhone': '+2250711111111',
        });
        expect(res.statusCode, 400);
      },
    );

    test('POST /wallet/transfer/internal — zero amount returns 400', () async {
      final res = await client.post('/wallet/transfer/internal', {
        'recipientPhone': '+2250711111111',
        'amount': 0,
      });
      expect(res.statusCode, 400);
    });

    test(
      'POST /wallet/transfer/internal — negative amount returns 400',
      () async {
        final res = await client.post('/wallet/transfer/internal', {
          'recipientPhone': '+2250711111111',
          'amount': -50,
        });
        expect(res.statusCode, 400);
      },
    );

    test(
      'POST /wallet/transfer/external — missing fields returns 400',
      () async {
        final res = await client.post('/wallet/transfer/external', {});
        expect(res.statusCode, 400);
      },
    );

    test('GET /wallet/transactions — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/wallet/transactions');
      expect(res.statusCode, 401);
    });
  });
}
