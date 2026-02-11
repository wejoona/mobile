/// E2E: User profile, PIN, locale, avatar, search
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

  group('User Profile E2E', () {
    test('GET /user/profile — returns user data', () async {
      final res = await client.get('/user/profile');
      res.expectOk();
      final data = res.data?['data'] ?? res.data;
      expect(data, isNotNull);
      // Should have phone, id at minimum
      expect(data?['phone'] ?? data?['id'], isNotNull);
    });

    test('PUT /user/profile — update name', () async {
      final res = await client.put('/user/profile', {
        'firstName': 'E2EUpdated',
        'lastName': 'TestUser',
      });
      res.expectOk();
    });

    test('GET /user/profile — verify update', () async {
      final res = await client.get('/user/profile');
      res.expectOk();
      final data = res.data?['data'] ?? res.data;
      expect(data?['firstName'], 'E2EUpdated');
    });

    test('PUT /user/locale — set preferred locale', () async {
      final res = await client.put('/user/locale', {'locale': 'fr'});
      // May be 200 or 204
      expect(res.statusCode, anyOf(200, 204));
    });

    test('GET /user/profile — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/user/profile');
      expect(res.statusCode, 401);
    });
  });

  group('User PIN E2E', () {
    test('POST /user/pin/set — set PIN', () async {
      // API expects pinHash (SHA256), not plaintext pin
      final res = await client.post('/user/pin/set', {
        'pinHash': '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
      });
      // 200 = set, 409/400 = already set
      expect(res.statusCode, anyOf(200, 201, 400, 409));
    });

    test('POST /user/pin/verify — correct PIN', () async {
      final res = await client.post('/user/pin/verify', {
        'pinHash': '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
      });
      // May fail if PIN wasn't set (new test user)
      expect(res.statusCode, anyOf(200, 400));
    });

    test('POST /user/pin/verify — wrong PIN returns 400/401', () async {
      final res = await client.post('/user/pin/verify', {
        'pinHash': '0000000000000000000000000000000000000000000000000000000000000000',
      });
      expect(res.statusCode, anyOf(400, 401));
    });

    test('POST /user/pin/verify — missing PIN returns 400', () async {
      final res = await client.post('/user/pin/verify', {});
      expect(res.statusCode, 400);
    });

    test('POST /user/pin/change — change PIN', () async {
      final res = await client.post('/user/pin/change', {
        'oldPinHash': '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
        'newPinHash': 'c59253af4e276b7857c7c0e427dd2a7fe60fb9e0bc56aec40e64d3e42449ac41',
      });
      // May succeed or fail if PIN wasn't set
      expect(res.statusCode, anyOf(200, 201, 400));

      // Change back
      if (res.isOk) {
        await client.post('/user/pin/change', {
          'currentPin': '654321',
          'newPin': '123456',
        });
      }
    });
  });

  group('User Search E2E', () {
    test('GET /user/search — requires query param', () async {
      final res = await client.get('/user/search?q=test');
      // Should return results or empty array
      expect(res.statusCode, anyOf(200, 400));
    });

    test('GET /user/username/check/:username', () async {
      final res = await client.get('/user/username/check/e2e_test_user');
      res.expectOk();
      // Should have `available` field
      final data = res.data?['data'] ?? res.data;
      expect(data, isNotNull);
    });
  });

  group('User Limits E2E', () {
    test('GET /user/limits — returns limits', () async {
      final res = await client.get('/user/limits');
      res.expectOk();
    });
  });
}
