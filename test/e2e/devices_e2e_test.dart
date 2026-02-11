/// E2E: Devices — register, list, sessions
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

  group('Devices E2E', () {
    test('POST /devices/register — register device', () async {
      final res = await client.post('/devices/register', {
        'deviceIdentifier': 'e2e-test-device-001',
        'platform': 'ios',
        'model': 'iPhone 16',
        'osVersion': '26.3',
        'appVersion': '1.0.0',
      });
      expect(res.statusCode, anyOf(200, 201));
    });

    test('GET /devices — list devices', () async {
      final res = await client.get('/devices');
      res.expectOk();
    });

    test('POST /devices/register — duplicate device is idempotent', () async {
      final res = await client.post('/devices/register', {
        'deviceIdentifier': 'e2e-test-device-001',
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

  group('Sessions E2E', () {
    test('GET /sessions — list active sessions', () async {
      final res = await client.get('/sessions');
      res.expectOk();
    });
  });
}
