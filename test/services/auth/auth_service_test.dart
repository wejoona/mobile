import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('AuthService', () {
    test('login keeps local phone internal but sends E.164 to API', () async {
      final dio = MockDio();
      final authService = AuthService(dio, MockSecureStorage());

      dio.queueResponse({
        'success': true,
        'message': 'OTP sent',
        'expiresIn': 300,
      });

      await authService.login(phone: '0748805663', countryCode: '+225');

      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/auth/login');
      expect(dio.requestHistory.single.data, {
        'phone': '+2250748805663',
        'countryCode': 'CI',
      });
    });

    test(
      'login repairs duplicated dial code before sending API body',
      () async {
        final dio = MockDio();
        final authService = AuthService(dio, MockSecureStorage());

        dio.queueResponse({
          'success': true,
          'message': 'OTP sent',
          'expiresIn': 300,
        });

        await authService.login(
          phone: '+225+2250748805663',
          countryCode: '+225',
        );

        expect(dio.requestHistory.single.method, 'POST');
        expect(dio.requestHistory.single.path, '/auth/login');
        expect(dio.requestHistory.single.data, {
          'phone': '+2250748805663',
          'countryCode': 'CI',
        });
      },
    );

    test('requestRecoveryOtp sends PIN reset recovery purpose', () async {
      final dio = MockDio();
      final authService = AuthService(dio, MockSecureStorage());

      dio.queueResponse({
        'success': true,
        'message': 'Recovery code sent',
        'expiresIn': 300,
      });

      await authService.requestRecoveryOtp(
        phone: '0748805663',
        countryCode: '+225',
      );

      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/auth/recovery/request-otp');
      expect(dio.requestHistory.single.data, {
        'phone': '+2250748805663',
        'countryCode': 'CI',
        'scope': 'pin_reset',
      });
    });

    test('register sends E.164 phone and ISO country code to API', () async {
      final dio = MockDio();
      final authService = AuthService(dio, MockSecureStorage());

      dio.queueResponse({
        'success': true,
        'message': 'OTP sent',
        'expiresIn': 300,
      });

      await authService.register(
        phone: '0748805663',
        countryCode: 'CI',
        acceptedTerms: true,
        termsVersion: 'terms-v1',
        privacyVersion: 'privacy-v1',
      );

      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/auth/register');
      expect(dio.requestHistory.single.data, {
        'phone': '+2250748805663',
        'countryCode': 'CI',
        'acceptedTerms': true,
        'termsVersion': 'terms-v1',
        'privacyVersion': 'privacy-v1',
      });
    });

    test('verifyOtp only verifies OTP and parses the auth response', () async {
      final dio = MockDio();
      final authService = AuthService(dio, MockSecureStorage());

      dio.queueResponse({
        'accessToken': 'access-token',
        'refreshToken': 'refresh-token',
        'walletCreated': true,
        'expiresIn': 900,
        'user': {
          'id': 'user-1',
          'phone': '+2250102030405',
          'countryCode': 'CI',
          'phoneVerified': true,
          'role': 'user',
          'status': 'active',
          'createdAt': '2026-05-25T00:00:00.000Z',
          'updatedAt': '2026-05-25T00:00:00.000Z',
        },
      });

      final response = await authService.verifyOtp(
        phone: '0102030405',
        countryCode: 'CI',
        otp: '123456',
      );

      expect(response.accessToken, 'access-token');
      expect(dio.requestHistory, hasLength(1));
      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/auth/verify-otp');
      expect(dio.requestHistory.single.data, {
        'phone': '+2250102030405',
        'countryCode': 'CI',
        'otp': '123456',
      });
    });

    test(
      'logout refreshes and retries when the access token is stale',
      () async {
        final dio = MockDio();
        final authService = AuthService(dio, MockSecureStorage());

        dio.queueErrorResponse(statusCode: 401);
        dio.queueResponse({
          'accessToken': 'fresh-access-token',
          'refreshToken': 'rotated-refresh-token',
          'expiresIn': 900,
        });
        dio.queueResponse({'success': true});

        await authService.logout(
          accessToken: 'stale-access-token',
          refreshToken: 'old-refresh-token',
        );

        expect(dio.requestHistory.map((request) => request.path), [
          '/auth/logout',
          '/auth/refresh',
          '/auth/logout',
        ]);
        expect(
          dio.requestHistory.first.headers['Authorization'],
          'Bearer stale-access-token',
        );
        expect(dio.requestHistory[1].data, {
          'refreshToken': 'old-refresh-token',
        });
        expect(
          dio.requestHistory.last.headers['Authorization'],
          'Bearer fresh-access-token',
        );
        expect(dio.requestHistory.last.data, {
          'refreshToken': 'rotated-refresh-token',
        });
      },
    );
  });
}
