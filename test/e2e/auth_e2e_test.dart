/// E2E: Auth cycle — register, login, OTP verify, token refresh, logout
library;

import 'package:test/test.dart';
import 'e2e_test_client.dart';

void main() {
  late E2EClient client;

  setUpAll(() {
    client = E2EClient();
  });

  group('Auth E2E', () {
    test('POST /auth/register — new user or already exists', () async {
      final res = await client.post('/auth/register', {
        'phone': testPhone,
        'countryCode': 'CI',
      });
      // 201 = new user, 200/409 = already exists
      expect(res.statusCode, anyOf(200, 201, 409));
    });

    test('POST /auth/login — sends OTP', () async {
      final res = await client.post('/auth/login', {'phone': testPhone});
      res.expectOk();
    });

    test('GET /dev/otp/:phone — retrieves OTP (dev mode)', () async {
      final res = await client.get('/dev/otp/${Uri.encodeComponent(testPhone)}');
      res.expectOk();
      expect(res.data!['data']['otp'], isNotNull);
    });

    test('POST /auth/verify-otp — valid OTP returns tokens', () async {
      // Wait to avoid rate limiting
      await Future.delayed(const Duration(seconds: 2));

      // Get OTP from dev endpoint
      final otpRes = await client.get('/dev/otp/${Uri.encodeComponent(testPhone)}');
      final otp = otpRes.data!['data']['otp'].toString();

      final res = await client.post('/auth/verify-otp', {
        'phone': testPhone,
        'otp': otp,
      });
      res.expectOk();

      final data = res.data?['data'] ?? res.data;
      final accessToken = data?['accessToken'] ?? data?['access_token'];
      final refreshToken = data?['refreshToken'] ?? data?['refresh_token'];
      expect(accessToken, isNotNull);
      expect(refreshToken, isNotNull);

      client.setTokens(
        access: accessToken.toString(),
        refresh: refreshToken.toString(),
      );
    });

    test('POST /auth/verify-otp — wrong OTP returns 400/401', () async {
      final res = await client.post('/auth/verify-otp', {
        'phone': testPhone,
        'otp': '000000',
      });
      expect(res.statusCode, anyOf(400, 401));
    });

    test('POST /auth/verify-otp — missing phone returns 400', () async {
      final res = await client.post('/auth/verify-otp', {'otp': '123456'});
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
      await client.loginFlow(testPhone);
      expect(client.accessToken, isNotNull);
    });
  });
}
