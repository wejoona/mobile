/// E2E: Notifications — list, preferences
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

  group('Notifications E2E', () {
    test('GET /notifications — list notifications', () async {
      final res = await client.get('/notifications');
      res.expectOk();
    });

    test('GET /notifications — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/notifications');
      expect(res.statusCode, 401);
    });
  });
}
