import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/auth/auth_service.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('AuthService', () {
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
        phone: '+2250102030405',
        otp: '123456',
      );

      expect(response.accessToken, 'access-token');
      expect(dio.requestHistory, hasLength(1));
      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/auth/verify-otp');
    });
  });
}
