/// E2E: Wallet transaction history and aggregate stats
library;

import 'package:test/test.dart';

import 'e2e_test_client.dart';

void main() {
  late E2EClient client;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
    await client.ensureWallet();
  });

  e2eGroup('Transactions E2E', () {
    test(
      'GET /wallet/transactions — returns screen history contract',
      () async {
        final res = await client.get('/wallet/transactions?limit=20&offset=0');
        res.expectOk();

        final data = res.data?['data'] ?? res.data;
        expect(data, isNotNull);
        expect(data, containsPair('transactions', isA<List<dynamic>>()));
        expect(data, containsPair('total', isA<int>()));
        expect(data, containsPair('limit', isA<int>()));
        expect(data, containsPair('offset', isA<int>()));
        expect(data, containsPair('hasMore', isA<bool>()));
      },
    );

    test(
      'GET /wallet/transactions/stats — returns aggregate contract',
      () async {
        final res = await client.get('/wallet/transactions/stats');
        res.expectOk();

        final data = res.data?['data'] ?? res.data;
        expect(data, isNotNull);
        expect(data, containsPair('totalTransactions', isA<int>()));
        expect(data, containsPair('totalDeposits', isA<int>()));
        expect(data, containsPair('totalWithdrawals', isA<int>()));
        expect(data, containsPair('totalTransfers', isA<int>()));
        expect(data, containsPair('currency', isA<String>()));
      },
    );

    test('GET /wallet/transactions — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/wallet/transactions');
      expect(res.statusCode, 401);
    });
  });
}
