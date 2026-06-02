import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';
import 'package:usdc_wallet/services/security/device_fingerprint_service.dart';

import '../../helpers/test_utils.dart';

class MockDeviceFingerprintService extends Mock
    implements DeviceFingerprintService {}

void main() {
  group('AuthService', () {
    test('login normalizes local Ivory Coast phone to E.164', () async {
      final dio = MockDio();
      final fingerprintService = MockDeviceFingerprintService();
      final authService = AuthService(dio, fingerprintService);

      dio.queueResponse({
        'success': true,
        'message': 'OTP sent',
        'expiresIn': 300,
      });

      await authService.login(phone: '07 00 00 00 00');

      final request = dio.requestHistory.single;
      expect(request.method, 'POST');
      expect(request.path, '/auth/login');
      expect(request.data, {'phone': '+2250700000000'});
    });

    test('register maps dial-code country input to ISO code', () async {
      final dio = MockDio();
      final fingerprintService = MockDeviceFingerprintService();
      final authService = AuthService(dio, fingerprintService);

      dio.queueResponse({
        'success': true,
        'message': 'OTP sent',
        'expiresIn': 300,
      });

      await authService.register(phone: '0700000000', countryCode: '+225');

      final request = dio.requestHistory.single;
      expect(request.method, 'POST');
      expect(request.path, '/auth/register');
      expect(request.data, {'phone': '+2250700000000', 'countryCode': 'CI'});
    });

    test(
      'verifyOtp normalizes remembered local phone before submission',
      () async {
        final dio = MockDio();
        final fingerprintService = MockDeviceFingerprintService();
        final authService = AuthService(dio, fingerprintService);

        when(fingerprintService.collect).thenAnswer(
          (_) async => const DeviceFingerprint(
            deviceId: 'ios-vendor-id',
            fingerprintHash: 'fingerprint-hash',
            brand: 'Apple',
            model: 'iPhone17,2',
            os: 'iOS',
            osVersion: '18.5',
            appVersion: '1.0.0',
            buildNumber: '42',
            locale: 'fr_CI',
            screenWidth: 430,
            screenHeight: 932,
            isPhysicalDevice: true,
            isCompromised: false,
            biometricsAvailable: true,
            platform: 'ios',
          ),
        );

        dio
          ..queueResponse({
            'accessToken': 'access-token',
            'refreshToken': 'refresh-token',
            'walletCreated': true,
            'expiresIn': 900,
            'user': {
              'id': 'user-1',
              'phone': '+2250700000000',
              'countryCode': 'CI',
              'phoneVerified': true,
              'role': 'user',
              'status': 'active',
              'createdAt': '2026-05-25T00:00:00.000Z',
              'updatedAt': '2026-05-25T00:00:00.000Z',
            },
          })
          ..queueResponse({'id': 'device-1'});

        await authService.verifyOtp(phone: '0700000000', otp: '123456');

        final request = dio.requestHistory.first;
        expect(request.method, 'POST');
        expect(request.path, '/auth/verify-otp');
        expect(request.data, {'phone': '+2250700000000', 'otp': '123456'});
      },
    );

    test(
      'verifyOtp registers the authenticated device through /devices/register',
      () async {
        final dio = MockDio();
        final fingerprintService = MockDeviceFingerprintService();
        final authService = AuthService(dio, fingerprintService);

        when(fingerprintService.collect).thenAnswer(
          (_) async => const DeviceFingerprint(
            deviceId: 'ios-vendor-id',
            fingerprintHash: 'fingerprint-hash',
            brand: 'Apple',
            model: 'iPhone17,2',
            os: 'iOS',
            osVersion: '18.5',
            appVersion: '1.0.0',
            buildNumber: '42',
            locale: 'fr_CI',
            screenWidth: 430,
            screenHeight: 932,
            isPhysicalDevice: true,
            isCompromised: false,
            biometricsAvailable: true,
            platform: 'ios',
          ),
        );

        dio
          ..queueResponse({
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
          })
          ..queueResponse({'id': 'device-1'});

        final response = await authService.verifyOtp(
          phone: '+2250102030405',
          otp: '123456',
        );

        expect(response.accessToken, 'access-token');
        await _waitForRequestCount(dio, 2);

        final registerRequest = dio.requestHistory[1];
        expect(registerRequest.method, 'POST');
        expect(registerRequest.path, '/devices/register');

        final payload = registerRequest.data as Map<String, dynamic>;
        expect(payload['deviceIdentifier'], 'ios-vendor-id');
        expect(payload['platform'], 'ios');
        expect(payload['deviceId'], isNull);
        expect(payload['fingerprintHash'], isNull);
        expect(
          payload['metadata'],
          containsPair('fingerprintHash', 'fingerprint-hash'),
        );
      },
    );
  });
}

Future<void> _waitForRequestCount(MockDio dio, int count) async {
  for (var i = 0; i < 20; i++) {
    if (dio.requestHistory.length >= count) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  fail('Expected at least $count requests, got ${dio.requestHistory.length}.');
}
