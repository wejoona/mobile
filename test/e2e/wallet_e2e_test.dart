/// E2E: Wallet balance, transactions, deposit channels, exchange rate
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

Map<String, String> _idempotencyHeaders() => {
  'X-Idempotency-Key': 'e2e-${DateTime.now().microsecondsSinceEpoch}',
};

void _expectRejectedOrUnavailable(E2EResponse res) {
  if (res.statusCode == 404 || res.statusCode == 501) {
    final error = res.data?['error'];
    final code = error is Map<String, dynamic> ? error['code'] : null;
    expect(code, anyOf('NOT_FOUND', 'NOT_IMPLEMENTED', 'FEATURE_UNAVAILABLE'));
    return;
  }

  expect(res.statusCode, anyOf(400, 401, 403));
}

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
    await client.ensureWallet();
  });

  e2eGroup('Wallet E2E', () {
    test('GET /wallet — returns balance', () async {
      final res = await client.get('/wallet');
      res.expectOk();
      final data = res.data?['data'] ?? res.data;
      expect(data, isNotNull);
    });

    test('GET /user/limits — returns transaction limits', () async {
      final res = await client.get('/user/limits');
      res.expectOk();
    });

    test('GET /deposits/providers — returns providers', () async {
      final res = await client.get('/deposits/providers');
      res.expectOk();
    });

    test(
      'GET /wallet/deposit/channels — returns mobile deposit channels',
      () async {
        final res = await client.get('/wallet/deposit/channels');
        res.expectOk();

        final raw = res.data?['data'] ?? res.data;
        expect(raw, isA<Map<String, dynamic>>());
        final data = raw! as Map<String, dynamic>;
        expect(data['channels'], isA<List<dynamic>>());
      },
    );

    test('GET /wallet/deposit/providers — returns provider alias', () async {
      final res = await client.get('/wallet/deposit/providers');
      res.expectOk();

      final raw = res.data?['data'] ?? res.data;
      expect(raw, isA<Map<String, dynamic>>());
      final data = raw! as Map<String, dynamic>;
      expect(data['providers'], isA<List<dynamic>>());
    });

    test('GET /wallet/exchange-rate — returns rate', () async {
      final res = await client.get(
        '/wallet/exchange-rate?sourceCurrency=XOF&targetCurrency=USD&amount=1000',
      );
      res.expectOk();
      final raw = res.data?['data'] ?? res.data;
      expect(raw, isA<Map<String, dynamic>>());
      final data = raw! as Map<String, dynamic>;
      expect(data['fromCurrency'], 'XOF');
      expect(data['toCurrency'], 'USD');
      expect(data['rate'], isA<num>());
      expect(data['rate'] as num, greaterThan(0));
      expect(data['timestamp'], isA<String>());
    });

    test('GET /kyc/status — returns KYC status', () async {
      final res = await client.get('/kyc/status');
      res.expectOk();
    });

    test('GET /wallet — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/wallet');
      expect(res.statusCode, 401);
    });
  });

  e2eGroup('Deposit E2E', () {
    test('POST /wallet/deposit — missing fields returns 400', () async {
      final res = await client.post(
        '/wallet/deposit',
        {},
        _idempotencyHeaders(),
      );
      expect(res.statusCode, anyOf(400, 428));
    });

    test('POST /wallet/deposit — invalid amount returns 400', () async {
      final res = await client.post('/wallet/deposit', {
        'amount': -100,
        'sourceCurrency': 'XOF',
        'channelId': 'orange_money_ci',
      }, _idempotencyHeaders());
      expect(res.statusCode, anyOf(400, 428));
    });

    test('POST /deposits/initiate — retired writer returns 410', () async {
      final res = await client.post(
        '/deposits/initiate',
        {},
        _idempotencyHeaders(),
      );
      expect(res.statusCode, 410);
      final error = res.data?['error'];
      expect(error, isA<Map<String, dynamic>>());
      expect(
        (error as Map<String, dynamic>)['code'],
        'DEPOSIT_WRITE_ENDPOINT_RETIRED',
      );
      expect(error['canonicalEndpoint'], '/api/v1/wallet/deposit');
    });

    test(
      'POST /deposits/initiate — retired before legacy validation',
      () async {
        final res = await client.post('/deposits/initiate', {
          'amount': -100,
          'currency': 'XOF',
          'providerCode': 'OMCI',
        }, _idempotencyHeaders());
        expect(res.statusCode, 410);
      },
    );
  });

  e2eGroup('Transfer E2E', () {
    test(
      'POST /wallet/transfer/internal — missing fields is rejected',
      () async {
        final res = await client.post('/wallet/transfer/internal', {});
        expect(res.statusCode, anyOf(400, 401, 403));
      },
    );

    test(
      'POST /wallet/transfer/external — missing fields is rejected',
      () async {
        final res = await client.post('/wallet/transfer/external', {});
        expect(res.statusCode, anyOf(400, 401, 403));
      },
    );

    test(
      'GET /wallet/transfer/external/estimate-fee — returns fee estimate',
      () async {
        final res = await client.get(
          '/wallet/transfer/external/estimate-fee?amount=100&network=stellar',
        );
        // May return 200 or 400 depending on query params validation
        expect(res.statusCode, anyOf(200, 400));
      },
    );
  });

  e2eGroup('Withdrawal E2E', () {
    test(
      'POST /wallet/transfer/external — missing auth factors is rejected',
      () async {
        final res = await client.post('/wallet/transfer/external', {
          'amount': 10,
          'toAddress': '0x1234567890abcdef1234567890abcdef12345678',
          'currency': 'USDC',
          'network': 'polygon',
        }, _idempotencyHeaders());
        expect(res.statusCode, anyOf(400, 401, 403));
      },
    );

    test(
      'GET /wallet/cash-out/mobile-money/options — returns rails or unavailable',
      () async {
        final res = await client.get(
          '/wallet/cash-out/mobile-money/options?country=CI',
        );
        if (res.isOk) {
          final raw = res.data?['data'] ?? res.data;
          expect(raw, isA<Map<String, dynamic>>());
          final data = raw! as Map<String, dynamic>;
          expect(data['options'], isA<List<dynamic>>());
        } else {
          _expectRejectedOrUnavailable(res);
        }
      },
    );

    test(
      'POST /wallet/cash-out/mobile-money — missing fields is rejected or unavailable',
      () async {
        final res = await client.post(
          '/wallet/cash-out/mobile-money',
          {},
          _idempotencyHeaders(),
        );
        _expectRejectedOrUnavailable(res);
      },
    );
  });
}
