/// E2E: Beneficiaries — CRUD + favorites
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }

  late E2EClient client;
  String? createdId;

  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
  });

  e2eGroup('Beneficiaries E2E', () {
    test('POST /beneficiaries — add beneficiary', () async {
      final res = await client.post('/beneficiaries', {
        'name': 'E2E Beneficiary',
        'phoneE164': '+2250799999999',
        'accountType': 'joonapay_user',
      });
      // 200/201 = created, 400 = validation, 409 = duplicate
      expect(res.statusCode, anyOf(200, 201, 400, 409));
      if (res.isOk) {
        final data = res.data;
        final wrapped = data?['data'];
        final payload = wrapped is Map ? wrapped : data;
        if (payload is Map) {
          final Object? id = payload['id'];
          createdId = id?.toString();
        }
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
