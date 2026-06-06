import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/state/app_state.dart';

import '../helpers/test_utils.dart';

void main() {
  group('UserProfile API contract', () {
    test('parses backend profile fields used by the app', () {
      final profile = UserProfile.fromJson({
        'id': 'usr_001',
        'phone': '+22507080910',
        'phoneVerified': true,
        'username': 'ben',
        'firstName': 'Ben',
        'lastName': 'Ouattara',
        'email': 'ben@korido.co',
        'emailVerified': true,
        'avatarUrl': '/user/avatar/usr_001',
        'avatarThumb': 'data:image/jpeg;base64,/9j/test',
        'preferredLocale': 'fr',
        'countryCode': 'CI',
        'kycStatus': 'verified',
        'kycRejectionReason': null,
        'canTransact': true,
        'canWithdraw': true,
        'hasPin': true,
        'role': 'user',
        'status': 'active',
        'createdAt': '2026-02-10T14:30:00Z',
        'updatedAt': '2026-02-11T09:00:00Z',
      });

      expect(profile.id, 'usr_001');
      expect(profile.phoneVerified, isTrue);
      expect(profile.avatarUrl, '/user/avatar/usr_001');
      expect(profile.avatarThumb, startsWith('data:image/jpeg;base64,'));
      expect(profile.preferredLocale, 'fr');
      expect(profile.canTransact, isTrue);
      expect(profile.canWithdraw, isTrue);
      expect(profile.hasPin, isTrue);
      expect(profile.displayName, 'Ben Ouattara');
    });

    test('accepts legacy avatar keys and missing optional profile fields', () {
      final profile = UserProfile.fromJson({
        'userId': 'usr_legacy',
        'avatar_url': '/user/avatar/usr_legacy',
        'avatarBase64': 'data:image/jpeg;base64,/9j/legacy',
      });

      expect(profile.id, 'usr_legacy');
      expect(profile.phone, isEmpty);
      expect(profile.avatarUrl, '/user/avatar/usr_legacy');
      expect(profile.avatarThumb, startsWith('data:image/jpeg;base64,'));
      expect(profile.countryCode, 'CI');
      expect(profile.kycStatus, 'none');
      expect(profile.role, 'user');
      expect(profile.status, 'active');
    });

    test('accepts enveloped profile and avatar upload aliases', () {
      final profile = UserProfile.fromJson({
        'user_id': 'usr_alias',
        'phone_verified': 'true',
        'first_name': 'Awa',
        'last_name': 'Kone',
        'email_verified': 'true',
        'avatar_url': '/user/avatar/usr_alias',
        'avatar_thumb': 'data:image/jpeg;base64,/9j/thumb',
        'preferred_locale': 'en',
        'country_code': 'US',
        'kyc_status': 'approved',
        'can_transact': 'true',
        'can_withdraw': true,
        'has_pin': 'true',
        'created_at': '2026-06-04T10:00:00.000Z',
      });
      final avatar = AvatarUploadResult.fromJson({
        'avatar_url': '/user/avatar/usr_alias',
        'avatar_thumb': 'data:image/jpeg;base64,/9j/thumb',
        'message': 'Avatar uploaded successfully',
      });

      expect(profile.id, 'usr_alias');
      expect(profile.displayName, 'Awa Kone');
      expect(profile.phoneVerified, isTrue);
      expect(profile.emailVerified, isTrue);
      expect(profile.avatarUrl, '/user/avatar/usr_alias');
      expect(profile.avatarThumb, startsWith('data:image/jpeg;base64,'));
      expect(profile.preferredLocale, 'en');
      expect(profile.countryCode, 'US');
      expect(profile.kycStatus, 'approved');
      expect(profile.canTransact, isTrue);
      expect(profile.canWithdraw, isTrue);
      expect(profile.hasPin, isTrue);
      expect(avatar.avatarUrl, '/user/avatar/usr_alias');
      expect(avatar.avatarThumb, startsWith('data:image/jpeg;base64,'));
    });

    test('user service unwraps standard profile envelopes', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'user_id': 'usr_enveloped',
            'first_name': 'Ben',
            'last_name': 'Ouattara',
            'avatar_url': '/user/avatar/usr_enveloped',
            'country_code': 'CI',
          },
        });
      final service = UserService(dio);

      final profile = await service.getProfile();

      expect(dio.requestHistory.single.path, '/user/profile');
      expect(profile.id, 'usr_enveloped');
      expect(profile.displayName, 'Ben Ouattara');
      expect(profile.avatarUrl, '/user/avatar/usr_enveloped');
      expect(profile.countryCode, 'CI');
    });
  });

  group('UserState avatar contract', () {
    test('can explicitly clear stale avatar URL and thumbnail values', () {
      const state = UserState(
        avatarUrl: '/user/avatar/usr_001',
        avatarThumb: 'data:image/jpeg;base64,/9j/test',
      );

      final cleared = state.copyWith(
        clearAvatarUrl: true,
        clearAvatarThumb: true,
      );

      expect(cleared.avatarUrl, isNull);
      expect(cleared.avatarThumb, isNull);
      expect(cleared.effectiveAvatarUrl, isNull);
    });
  });
}
