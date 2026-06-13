import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/storage/hive_models.dart';
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

    test('user service can explicitly clear profile email', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': {'id': 'usr_clear_email', 'email': null},
        });
      final service = UserService(dio);

      final profile = await service.updateProfile(clearEmail: true);

      expect(dio.requestHistory.single.path, '/user/profile');
      expect(dio.requestHistory.single.data, {'email': null});
      expect(profile.email, isNull);
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

    test('can explicitly clear stale profile email', () {
      const state = UserState(email: 'old@korido.co', emailVerified: true);

      final cleared = state.copyWith(clearEmail: true, emailVerified: false);

      expect(cleared.email, isNull);
      expect(cleared.emailVerified, isFalse);
    });

    test('profile edit screen rebuilds after hydrating existing avatar', () {
      final source = File(
        'lib/features/settings/views/profile_edit_screen.dart',
      ).readAsStringSync();
      final initStateBody = RegExp(
        r'void initState\(\) \{([\s\S]*?)\n  @override\n  void dispose',
      ).firstMatch(source)!.group(1)!;

      expect(initStateBody, contains('addPostFrameCallback'));
      expect(initStateBody, contains('if (!mounted) return'));
      expect(initStateBody, contains('setState'));
      expect(initStateBody, contains('_avatarUrl = userState.avatarUrl'));
      expect(initStateBody, contains('_avatarThumb = userState.avatarThumb'));
    });

    test('avatar upload paths clear stale local avatar cache', () {
      final userStateSource = File(
        'lib/state/user_state_machine.dart',
      ).readAsStringSync();
      final profileProviderSource = File(
        'lib/features/profile/providers/profile_provider.dart',
      ).readAsStringSync();
      final profileEditSource = File(
        'lib/features/settings/views/profile_edit_screen.dart',
      ).readAsStringSync();

      expect(userStateSource, contains('Future<void> applyServerAvatar'));
      expect(userStateSource, contains('await _clearLocalAvatarCache();'));
      expect(userStateSource, contains("delete(key: 'local_avatar_path')"));
      expect(profileProviderSource, contains('await _applyAvatarUploadResult'));
      expect(profileProviderSource, contains('applyServerAvatar('));
      expect(profileEditSource, contains('detectFaces(compressed)'));
      expect(profileEditSource, contains('Checking face on this device'));
      expect(profileEditSource, contains('_profilePhotoPickErrorMessage'));
      expect(profileEditSource, contains('PlatformException'));
      expect(profileEditSource, contains('uploadAvatar(compressed)'));
      expect(profileEditSource, contains('_selectedImage = null'));
    });

    test('cached profile preserves avatar thumbnail for offline rendering', () {
      final cached = CachedUserProfile(
        userId: 'usr_cached',
        avatarUrl: '/user/avatar/usr_cached',
        avatarThumb: 'data:image/jpeg;base64,/9j/cached',
        countryCode: 'CI',
        kycStatus: 'approved',
        cachedAt: DateTime.parse('2026-06-04T10:00:00.000Z'),
      );
      final syncSource = File(
        'lib/services/storage/sync_service.dart',
      ).readAsStringSync();
      final userStateSource = File(
        'lib/state/user_state_machine.dart',
      ).readAsStringSync();

      expect(cached.avatarThumb, startsWith('data:image/jpeg;base64,'));
      expect(syncSource, contains('avatarThumb: state.avatarThumb'));
      expect(userStateSource, contains('avatarThumb: cached.avatarThumb'));
    });
  });
}
