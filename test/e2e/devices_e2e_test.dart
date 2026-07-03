/// E2E: Devices — register, list, sessions
library;

import 'dart:convert';

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }

  late E2EClient client;
  String? registeredDeviceId;

  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
  });

  e2eGroup('Devices E2E', () {
    test('POST /devices/register — register device', () async {
      final res = await client.post('/devices/register', {
        'deviceIdentifier': client.deviceIdentifier,
        'platform': 'ios',
        'model': 'iPhone 16',
        'osVersion': '26.3',
        'appVersion': '1.0.0',
      });
      expect(res.statusCode, anyOf(200, 201));
      final device = jsonDecode(res.body) as Map<String, dynamic>;
      registeredDeviceId = device['id'] as String?;
      expect(registeredDeviceId, isNotNull);
    });

    test('GET /devices — list devices', () async {
      final res = await client.get('/devices');
      res.expectOk();
    });

    test('POST /devices/register — duplicate device is idempotent', () async {
      final res = await client.post('/devices/register', {
        'deviceIdentifier': client.deviceIdentifier,
        'platform': 'ios',
        'model': 'iPhone 16',
        'osVersion': '26.3',
        'appVersion': '1.0.0',
      });
      expect(res.statusCode, anyOf(200, 201));
    });

    test('GET /devices — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/devices');
      expect(res.statusCode, 401);
    });
  });

  e2eGroup('Sessions E2E', () {
    test('GET /sessions — list active sessions', () async {
      final res = await client.get('/sessions');
      res.expectOk();
      final payload = jsonDecode(res.body);
      final sessions = switch (payload) {
        {'sessions': final List<dynamic> items} => items,
        {'items': final List<dynamic> items} => items,
        final List<dynamic> items => items,
        _ => <dynamic>[],
      };
      expect(sessions, isA<List<dynamic>>());
      expect(sessions, isNotEmpty);
      expect(sessions.first, isA<Map<String, dynamic>>());
      expect((sessions.first as Map<String, dynamic>)['isActive'], isTrue);
      expect(
        sessions,
        contains(
          predicate<dynamic>(
            (session) =>
                session is Map<String, dynamic> &&
                session['deviceId'] == registeredDeviceId,
          ),
        ),
      );
    });

    test('GET /sessions — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/sessions');
      expect(res.statusCode, 401);
    });
  });
}
