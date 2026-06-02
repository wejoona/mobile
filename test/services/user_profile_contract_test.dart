import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/state/app_state.dart';

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
