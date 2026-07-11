/// E2E: Auth cycle — register, login, OTP verify, token refresh, logout
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  if (!e2eEnabled) {
    skipE2ESuite();
    return;
  }

  late E2EClient client;
  late String authPhone;
  late String wrongOtpPhone;

  if (!runLiveE2E) {
    test('Live E2E disabled', () {}, skip: liveE2ESkipReason);
    return;
  }

  setUpAll(() {
    client = E2EClient();
    authPhone = uniqueE2EPhone();
    wrongOtpPhone = uniqueE2EPhone();
  });

  e2eGroup('Auth E2E', () {
    test('POST /auth/register — new user or already exists', () async {
      final consentPayload = await client.registrationConsentPayload();
      final res = await client.post('/auth/register', {
        'phone': authPhone,
        'countryCode': 'CI',
        ...consentPayload,
      });
      // 201 = new user, 200/409 = already exists
      expect(res.statusCode, anyOf(200, 201, 409));
    });

    test('POST /auth/login — sends OTP', () async {
      final res = await client.post('/auth/login', {'phone': authPhone});
      res.expectOk();
    });

    test('GET /dev/otp/:phone — staging keeps OTP debug state private', () async {
      final res = await client.get(
        '/dev/otp/${Uri.encodeComponent(authPhone)}',
      );
      expect(res.statusCode, anyOf(403, 404));
      if (res.statusCode == 200) {
        expect(res.data!['data'], isNotNull);
      } else {
        final error = res.data?['error'] as Map<String, dynamic>?;
        expect(error?['code'], 'NOT_FOUND');
      }
    });

    test('POST /auth/verify-otp — valid OTP returns tokens', () async {
      // Wait to avoid rate limiting
      await Future.delayed(const Duration(seconds: 2));

      // Get OTP from dev endpoint
      final otpRes = await client.get(
        '/dev/otp/${Uri.encodeComponent(authPhone)}',
      );
      final otpPayload = otpRes.data?['data'] as Map<String, dynamic>?;
      final otp = otpPayload?['otp']?.toString() ?? defaultTestOtp;

      final res = await client.post('/auth/verify-otp', {
        'phone': authPhone,
        'otp': otp,
      });
      res.expectOk();

      final data = _payload(res);
      final accessToken = data['accessToken'] ?? data['access_token'];
      final refreshToken = data['refreshToken'] ?? data['refresh_token'];
      expect(accessToken, isNotNull);
      expect(refreshToken, isNotNull);

      client.setTokens(
        access: accessToken.toString(),
        refresh: refreshToken.toString(),
      );
    });

    test('POST /auth/verify-otp — wrong OTP returns 400/401', () async {
      final consentPayload = await client.registrationConsentPayload();
      final registerRes = await client.post('/auth/register', {
        'phone': wrongOtpPhone,
        'countryCode': 'CI',
        ...consentPayload,
      });
      expect(registerRes.statusCode, anyOf(200, 201, 409));

      final res = await client.post('/auth/verify-otp', {
        'phone': wrongOtpPhone,
        'otp': '000000',
      });
      expect(res.statusCode, anyOf(400, 401));
    });

    test('POST /auth/verify-otp — missing phone returns 400', () async {
      final res = await client.post('/auth/verify-otp', {
        'otp': defaultTestOtp,
      });
      expect(res.statusCode, 400);
    });

    test('POST /auth/refresh — valid refresh token', () async {
      final ok = await client.refreshAccessToken();
      expect(ok, isTrue);
      expect(client.accessToken, isNotNull);
    });

    test('POST /auth/logout — invalidates session', () async {
      // Logout requires refreshToken in body
      final res = await client.post('/auth/logout', {
        'refreshToken': client.refreshToken ?? '',
      });
      res.expectOk();
    });

    test('Re-login for subsequent tests', () async {
      await client.loginFlow(uniqueE2EPhone());
      expect(client.accessToken, isNotNull);
    });
  });
}

Map<String, dynamic> _payload(E2EResponse res) {
  final body = res.data ?? <String, dynamic>{};
  final data = body['data'];
  return data is Map<String, dynamic> ? data : body;
}
