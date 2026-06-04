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

    test('GET /notifications/unread/count — returns count contract', () async {
      final res = await client.get('/notifications/unread/count');
      res.expectOk();

      final data = res.data;
      final nested = data?['data'];
      final count = nested is Map<String, dynamic>
          ? nested['count']
          : data?['count'];

      expect(count, isA<int>());
    });

    test(
      'POST and DELETE /notifications/push/token — manages push token',
      () async {
        const token = 'e2e-fcm-token-notifications-001';
        final registerRes = await client.post('/notifications/push/token', {
          'token': token,
          'platform': 'ios',
          'deviceId': 'e2e-test-device-001',
          'deviceName': 'E2E iPhone',
          'appVersion': '1.0.0',
          'osVersion': '26.5',
        });
        expect(registerRes.statusCode, anyOf(200, 201));

        final removeRes = await client.delete(
          '/notifications/push/token',
          null,
          {'token': token},
        );
        expect(removeRes.statusCode, anyOf(200, 204));
      },
    );

    test('GET and PUT /user/notification-preferences', () async {
      final getRes = await client.get('/user/notification-preferences');
      getRes.expectOk();

      final current = getRes.data!;
      expect(current['pushEnabled'], isA<bool>());
      expect(current['smsSecurity'], true);

      final nextPushMarketing = !(current['pushMarketing'] as bool? ?? false);
      final updateRes = await client.put('/user/notification-preferences', {
        'pushMarketing': nextPushMarketing,
        'largeTransactionThreshold': 1250,
        'lowBalanceThreshold': 75,
      });
      updateRes.expectOk();

      expect(updateRes.data?['pushMarketing'], nextPushMarketing);
      expect(updateRes.data?['largeTransactionThreshold'], 1250);
      expect(updateRes.data?['lowBalanceThreshold'], 75);
      expect(updateRes.data?['smsSecurity'], true);
    });

    test('GET /notifications — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/notifications');
      expect(res.statusCode, 401);
    });
  });
}
