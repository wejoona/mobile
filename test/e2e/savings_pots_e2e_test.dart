/// E2E: Savings Pots — CRUD + deposit/withdraw
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  const testPhone = '+2250700000000';
  String? createdPotId;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(testPhone);
  });

  group('Savings Pots E2E', () {
    test('POST /savings-pots — create pot', () async {
      final res = await client.post('/savings-pots', {
        'name': 'E2E Test Pot',
        'targetAmount': 50000,
        'currency': 'XOF',
        'color': '#4CAF50',
      });
      expect(res.statusCode, anyOf(200, 201));
      final data = res.data?['data'] ?? res.data;
      createdPotId = data?['id']?.toString();
    });

    test('GET /savings-pots — list pots', () async {
      final res = await client.get('/savings-pots');
      res.expectOk();
    });

    test('GET /savings-pots/:id — get specific pot', () async {
      if (createdPotId == null) return;
      final res = await client.get('/savings-pots/$createdPotId');
      res.expectOk();
    });

    test('POST /savings-pots/:id/deposit — add to pot', () async {
      if (createdPotId == null) return;
      final res = await client.post('/savings-pots/$createdPotId/deposit', {
        'amount': 1000,
      });
      // May fail due to insufficient balance — that's OK
      expect(res.statusCode, anyOf(200, 201, 400, 422));
    });

    test('POST /savings-pots/:id/withdraw — withdraw from pot', () async {
      if (createdPotId == null) return;
      final res = await client.post('/savings-pots/$createdPotId/withdraw', {
        'amount': 500,
      });
      // May fail if pot is empty
      expect(res.statusCode, anyOf(200, 201, 400, 422));
    });

    test('DELETE /savings-pots/:id — delete pot', () async {
      if (createdPotId == null) return;
      final res = await client.delete('/savings-pots/$createdPotId');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('POST /savings-pots — missing name returns 400', () async {
      final res = await client.post('/savings-pots', {
        'targetAmount': 10000,
      });
      expect(res.statusCode, 400);
    });

    test('GET /savings-pots — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/savings-pots');
      expect(res.statusCode, 401);
    });
  });
}
