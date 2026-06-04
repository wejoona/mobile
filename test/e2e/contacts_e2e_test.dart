/// E2E: Contacts — sync, list, invite
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
  });

  e2eGroup('Contacts E2E', () {
    test('GET /contacts — list contacts', () async {
      final res = await client.get('/contacts');
      res.expectOk();
    });

    test('POST /contacts/sync — sync device contacts', () async {
      final res = await client.post('/contacts/sync', {
        'phoneHashes': [
          'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        ],
      });
      res.expectOk();
    });

    test('GET /contacts/lookup — search discoverable Korido users', () async {
      final res = await client.get('/contacts/lookup?query=awa');
      res.expectOk();

      final data = res.data;
      expect(data, isNotNull);
      final nestedData = data?['data'];
      final users =
          data?['users'] ??
          (nestedData is Map<String, dynamic> ? nestedData['users'] : null);
      expect(users, isA<List<dynamic>>());
    });

    test('POST /contacts/invite — invite non-Korido contact', () async {
      final res = await client.post('/contacts/invite', {
        'phone': '+2250701234567',
      });
      res.expectOk();

      final data = res.data;
      expect(data, isNotNull);
      expect(data?['success'], isA<bool>());
      expect(data?['message'], isA<String>());
    });

    test('GET /contacts — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/contacts');
      expect(res.statusCode, 401);
    });
  });
}
