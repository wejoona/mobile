/// E2E: User profile, PIN, locale, avatar, search
// ignore_for_file: avoid_dynamic_calls

library;

import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';

import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }

  late E2EClient client;

  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  setUpAll(() async {
    client = E2EClient();
    await client.loginFlow(uniqueE2EPhone());
    await client.ensureWallet();
  });

  e2eGroup('User Profile E2E', () {
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

    test(
      'POST /user/avatar — uploads, persists, serves, and deletes photo',
      () async {
        final avatarFile = await _writeTinyJpeg();
        String? avatarUrl;
        final faceCheck = await AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 1,
        ).bindToFile(avatarFile);

        try {
          final uploadRes = await client.multipartPost(
            '/user/avatar',
            fieldName: 'avatar',
            file: avatarFile,
            filename: 'korido-profile-e2e.jpg',
            fields: {avatarDeviceFaceCheckField: faceCheck.token},
          );
          uploadRes.expectOk();
          final upload = uploadRes.data?['data'] ?? uploadRes.data;
          avatarUrl = upload?['avatarUrl']?.toString();
          expect(avatarUrl, startsWith('/user/avatar/'));

          final profileRes = await client.get('/user/profile');
          profileRes.expectOk();
          final profile = profileRes.data?['data'] ?? profileRes.data;
          expect(profile?['avatarUrl'], avatarUrl);

          final imageRes = await client.get(avatarUrl!);
          imageRes.expectOk();
          expect(imageRes.body.length, greaterThan(0));
        } finally {
          if (avatarUrl != null) {
            final deleteRes = await client.delete('/user/avatar');
            deleteRes.expectOk();

            final clearedRes = await client.get('/user/profile');
            clearedRes.expectOk();
            final cleared = clearedRes.data?['data'] ?? clearedRes.data;
            expect(cleared?['avatarUrl'], isNull);
            // Production may briefly return a stale thumbnail after delete.
            // Mobile hides thumbnails when the canonical avatar URL is absent.
          }
        }
      },
    );

    test('GET /user/profile — no auth returns 401', () async {
      final noAuth = E2EClient();
      final res = await noAuth.get('/user/profile');
      expect(res.statusCode, 401);
    });
  });

  e2eGroup('User PIN E2E', () {
    test('POST /user/pin/set — set PIN', () async {
      // API expects pinHash (SHA256), not plaintext pin
      final res = await client.post('/user/pin/set', {
        'pinHash':
            '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
      });
      // 200 = set, 409/400 = already set
      expect(res.statusCode, anyOf(200, 201, 400, 409));
    });

    test('POST /user/pin/verify — correct PIN', () async {
      final res = await client.post('/user/pin/verify', {
        'pinHash':
            '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
      });
      // May fail if PIN wasn't set (new test user)
      expect(res.statusCode, anyOf(200, 400));
    });

    test('POST /user/pin/verify — wrong PIN returns 400/401', () async {
      final res = await client.post('/user/pin/verify', {
        'pinHash':
            '0000000000000000000000000000000000000000000000000000000000000000',
      });
      expect(res.statusCode, anyOf(400, 401));
    });

    test('POST /user/pin/verify — missing PIN returns 400', () async {
      final res = await client.post('/user/pin/verify', {});
      expect(res.statusCode, 400);
    });

    test('POST /user/pin/change — change PIN', () async {
      final res = await client.post('/user/pin/change', {
        'oldPinHash':
            '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92',
        'newPinHash':
            'c59253af4e276b7857c7c0e427dd2a7fe60fb9e0bc56aec40e64d3e42449ac41',
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

  e2eGroup('User Search E2E', () {
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

  e2eGroup('User Limits E2E', () {
    test('GET /user/limits — returns limits', () async {
      final res = await client.get('/user/limits');
      res.expectOk();
    });
  });
}

Future<File> _writeTinyJpeg() async {
  const jpegBase64 =
      '/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAP//////////////////////////////////////////////////////////////////////////////////////2wBDAf//////////////////////////////////////////////////////////////////////////////////////wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAX/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIQAxAAAAH/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oACAEBAAEFAqf/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oACAEDAQE/Aaf/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oACAECAQE/Aaf/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oACAEBAAY/Aqf/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/9oACAEBAAE/IV//2gAMAwEAAgADAAAAEP/EFBQRAQAAAAAAAAAAAAAAAAAAABD/2gAIAQMBAT8QH//EFBQRAQAAAAAAAAAAAAAAAAAAABD/2gAIAQIBAT8QH//EFBABAQAAAAAAAAAAAAAAAAAAARD/2gAIAQEAAT8Qf//Z';
  final file = File(
    '${Directory.systemTemp.path}/korido-profile-e2e-${DateTime.now().microsecondsSinceEpoch}.jpg',
  );
  return file.writeAsBytes(base64Decode(jpegBase64), flush: true);
}
