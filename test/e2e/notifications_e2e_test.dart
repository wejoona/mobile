/// E2E: Notifications — list, preferences
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
  });

  e2eGroup('Notifications E2E', () {
    test('GET /notifications — list notifications', () async {
      final res = await client.get('/notifications');
      res.expectOk();
    });

    test('GET /notifications/unread-count — returns count contract', () async {
      final res = await client.get('/notifications/unread-count');
      res.expectOk();

      final data = res.data;
      final nested = data?['data'];
      final count = nested is Map<String, dynamic>
          ? nested['count']
          : data?['count'];

      expect(count, isA<int>());
    });

    test(
      'POST and DELETE /notifications/device-token — manages push token',
      () async {
        const token = 'e2e-fcm-token-notifications-001';
        final registerRes = await client.post('/notifications/device-token', {
          'token': token,
          'platform': 'ios',
        });
        expect(registerRes.statusCode, anyOf(200, 201));

        final removeRes = await client.delete(
          '/notifications/device-token/$token',
          null,
          null,
        );
        expect(removeRes.statusCode, anyOf(200, 204));
      },
    );

    test('GET and PUT /notifications/preferences', () async {
      final getRes = await client.get('/notifications/preferences');
      getRes.expectOk();

      final current =
          (getRes.data?['data'] ?? getRes.data)! as Map<String, dynamic>;
      expect(current['channels'], isA<Map<String, dynamic>>());
      expect(current['categories'], isA<Map<String, dynamic>>());

      final categories = current['categories'] as Map<String, dynamic>;
      final nextMarketing = !(categories['marketing'] as bool? ?? false);
      final updateRes = await client.put('/notifications/preferences', {
        'channels': current['channels'],
        'categories': {...categories, 'marketing': nextMarketing},
      });
      updateRes.expectOk();

      final updated =
          (updateRes.data?['data'] ?? updateRes.data)! as Map<String, dynamic>;
      expect(updated['categories']?['marketing'], nextMarketing);
    });

    test('GET /notifications — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/notifications');
      expect(res.statusCode, 401);
    });
  });
}
