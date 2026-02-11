/// E2E: Beneficiaries — CRUD + favorites
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;
  const testPhone = '+2250700000000';
  String? createdId;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(testPhone);
  });

  group('Beneficiaries E2E', () {
    test('POST /beneficiaries — add beneficiary', () async {
      final res = await client.post('/beneficiaries', {
        'name': 'E2E Beneficiary',
        'phone': '+2250799999999',
        'isFavorite': false,
      });
      expect(res.statusCode, anyOf(200, 201));
      if (res.isOk) {
        final data = res.data?['data'] ?? res.data;
        createdId = data?['id']?.toString();
      }
    });

    test('GET /beneficiaries — list beneficiaries', () async {
      final res = await client.get('/beneficiaries');
      res.expectOk();
    });

    test('GET /beneficiaries/:id — get specific', () async {
      if (createdId == null) return;
      final res = await client.get('/beneficiaries/$createdId');
      res.expectOk();
    });

    test('DELETE /beneficiaries/:id — remove', () async {
      if (createdId == null) return;
      final res = await client.delete('/beneficiaries/$createdId');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('POST /beneficiaries — missing name returns 400', () async {
      final res = await client.post('/beneficiaries', {
        'phone': '+2250799999999',
      });
      expect(res.statusCode, 400);
    });

    test('GET /beneficiaries — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/beneficiaries');
      expect(res.statusCode, 401);
    });
  });
}
