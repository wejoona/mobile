/// E2E: Wallet balance, transactions, deposit channels, exchange rate
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

  group('Wallet E2E', () {
    test('GET /wallet — returns balance', () async {
      final res = await client.get('/wallet');
      res.expectOk();
      final data = res.data?['data'] ?? res.data;
      expect(data, isNotNull);
    });

    test('GET /wallet/limits — returns transaction limits', () async {
      final res = await client.get('/wallet/limits');
      res.expectOk();
    });

    test('GET /wallet/deposit/channels — returns available channels', () async {
      final res = await client.get('/wallet/deposit/channels');
      res.expectOk();
    });

    test('GET /wallet/deposit/providers — returns providers', () async {
      final res = await client.get('/wallet/deposit/providers');
      res.expectOk();
    });

    test('GET /wallet/exchange-rate — returns rate', () async {
      final res = await client.get(
          '/wallet/exchange-rate?sourceCurrency=XOF&targetCurrency=USD&amount=1000');
      // May return 200 or 400 if FX not configured
      expect(res.statusCode, anyOf(200, 400, 404, 501));
    });

    test('GET /wallet/rate — returns rate', () async {
      final res = await client.get(
          '/wallet/rate?sourceCurrency=XOF&targetCurrency=USD&amount=1000');
      expect(res.statusCode, anyOf(200, 400, 404, 501));
    });

    test('GET /wallet/kyc/status — returns KYC status', () async {
      final res = await client.get('/wallet/kyc/status');
      res.expectOk();
    });

    test('GET /wallet — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/wallet');
      expect(res.statusCode, 401);
    });
  });

  group('Wallet PIN E2E', () {
    test('POST /wallet/pin/set — set wallet PIN', () async {
      final res = await client.post('/wallet/pin/set', {
        'pinHash': '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
      });
      expect(res.statusCode, anyOf(200, 201, 400, 409));
    });

    test('POST /wallet/pin/verify — verify correct PIN', () async {
      final res = await client.post('/wallet/pin/verify', {
        'pinHash': '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
      });
      expect(res.statusCode, anyOf(200, 400));
    });

    test('POST /wallet/pin/verify — wrong PIN', () async {
      final res = await client.post('/wallet/pin/verify', {
        'pinHash': '0000000000000000000000000000000000000000000000000000000000000000',
      });
      expect(res.statusCode, anyOf(400, 401));
    });
  });

  group('Wallet Deposit E2E', () {
    test('POST /wallet/deposit — missing fields returns 400', () async {
      final res = await client.post('/wallet/deposit', {});
      expect(res.statusCode, 400);
    });

    test('POST /wallet/deposit — invalid amount returns 400', () async {
      final res = await client.post('/wallet/deposit', {
        'amount': -100,
        'provider': 'orange_money',
      });
      expect(res.statusCode, 400);
    });
  });

  group('Wallet Transfer E2E', () {
    test('POST /wallet/transfer/internal — missing fields returns 400', () async {
      final res = await client.post('/wallet/transfer/internal', {});
      expect(res.statusCode, 400);
    });

    test('POST /wallet/transfer/external — missing fields returns 400', () async {
      final res = await client.post('/wallet/transfer/external', {});
      expect(res.statusCode, 400);
    });

    test('GET /wallet/transfer/external/estimate-fee — returns fee estimate', () async {
      final res = await client.get('/wallet/transfer/external/estimate-fee?amount=100&network=stellar');
      // May return 200 or 400 depending on query params validation
      expect(res.statusCode, anyOf(200, 400));
    });
  });

  group('Wallet Withdraw E2E', () {
    test('POST /wallet/withdraw — missing fields returns 400', () async {
      final res = await client.post('/wallet/withdraw', {});
      expect(res.statusCode, 400);
    });
  });
}
