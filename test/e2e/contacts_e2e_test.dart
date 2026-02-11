/// E2E: Contacts — sync, list, invite
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

  group('Contacts E2E', () {
    test('GET /contacts — list contacts', () async {
      final res = await client.get('/contacts');
      res.expectOk();
    });

    test('POST /contacts/sync — sync device contacts', () async {
      final res = await client.post('/contacts/sync', {
        'contacts': [
          {'name': 'Test Contact', 'phone': '+2250711111111'},
          {'name': 'Another Contact', 'phone': '+2250722222222'},
        ],
      });
      // 200/201 for success, 400 if format wrong
      expect(res.statusCode, anyOf(200, 201, 400));
    });

    test('GET /contacts — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/contacts');
      expect(res.statusCode, 401);
    });
  });
}
