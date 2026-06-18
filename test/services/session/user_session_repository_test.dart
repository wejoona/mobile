import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/session/user_session.dart';
import 'package:usdc_wallet/services/session/user_session_repository.dart';

import '../../helpers/test_utils.dart';

void main() {
  group('UserSessionRepository', () {
    test('persists remembered phone as dial code plus local number', () async {
      final storage = MockSecureStorage();
      final repository = UserSessionRepository(storage);
      final now = DateTime(2026, 6, 17, 12);

      await repository.save(
        UserSession(
          userId: 'user-1',
          phoneNumber: '+2250748805663',
          countryCode: 'CI',
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenExpiresAt: now.add(const Duration(minutes: 15)),
          lastActive: now,
          sessionCreatedAt: now,
        ),
      );

      expect(
        await repository.getRememberedPhone(),
        'CI|+225|0748805663|+2250748805663',
      );
    });

    test('uses the phone prefix when country code is missing', () async {
      final storage = MockSecureStorage();
      final repository = UserSessionRepository(storage);
      final now = DateTime(2026, 6, 17, 12);

      await repository.save(
        UserSession(
          userId: 'user-1',
          phoneNumber: '+14155550101',
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          tokenExpiresAt: now.add(const Duration(minutes: 15)),
          lastActive: now,
          sessionCreatedAt: now,
        ),
      );

      expect(
        await repository.getRememberedPhone(),
        'US|+1|4155550101|+14155550101',
      );
    });
  });
}
