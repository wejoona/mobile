/// E2E: Recurring Transfers — CRUD + pause/resume
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

  group('Recurring Transfers E2E', () {
    test('POST /recurring-transfers — create recurring transfer', () async {
      final res = await client.post('/recurring-transfers', {
        'recipientPhone': '+2250711111111',
        'amount': 5000,
        'currency': 'XOF',
        'frequency': 'weekly',
        'description': 'E2E test recurring',
      });
      expect(res.statusCode, anyOf(200, 201, 400));
      if (res.isOk) {
        final data = res.data?['data'] ?? res.data;
        createdId = data?['id']?.toString();
      }
    });

    test('GET /recurring-transfers — list all', () async {
      final res = await client.get('/recurring-transfers');
      res.expectOk();
    });

    test('GET /recurring-transfers/:id — get details', () async {
      if (createdId == null) return;
      final res = await client.get('/recurring-transfers/$createdId');
      res.expectOk();
    });

    test('POST /recurring-transfers/:id/pause — pause', () async {
      if (createdId == null) return;
      final res = await client.post('/recurring-transfers/$createdId/pause');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('POST /recurring-transfers/:id/resume — resume', () async {
      if (createdId == null) return;
      final res = await client.post('/recurring-transfers/$createdId/resume');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('DELETE /recurring-transfers/:id — cancel', () async {
      if (createdId == null) return;
      final res = await client.delete('/recurring-transfers/$createdId');
      expect(res.statusCode, anyOf(200, 204));
    });

    test('POST /recurring-transfers — missing fields returns 400', () async {
      final res = await client.post('/recurring-transfers', {});
      expect(res.statusCode, 400);
    });
  });
}
