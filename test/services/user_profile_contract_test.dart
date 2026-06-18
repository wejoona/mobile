import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
import 'package:usdc_wallet/services/session/user_session.dart';
import 'package:usdc_wallet/services/storage/hive_models.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';
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
      expect(profile.username, 'ben');
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

    test('core user entity accepts backend avatar aliases', () {
      final user = User.fromJson({
        'id': 'usr_avatar',
        'phone': '+2250748805663',
        'firstName': 'Ben',
        'lastName': 'Ouattara',
        'avatar_url': '/user/avatar/usr_avatar?v=123',
        'avatar_thumb': 'data:image/jpeg;base64,/9j/thumb',
        'countryCode': 'CI',
        'phoneVerified': true,
        'role': 'user',
        'status': 'active',
        'hasPin': true,
        'createdAt': '2026-06-04T10:00:00.000Z',
        'updatedAt': '2026-06-04T10:00:00.000Z',
      });

      expect(user.avatarUrl, '/user/avatar/usr_avatar?v=123');
      expect(user.avatarBase64, startsWith('data:image/jpeg;base64,'));
      expect(user.displayName, 'Ben Ouattara');
    });

    test(
      'core user entity can clear stale avatar thumbnail after replacement',
      () {
        final user = User.fromJson({
          'id': 'usr_avatar',
          'phone': '+2250748805663',
          'avatarUrl': '/user/avatar/usr_avatar?v=123',
          'avatarThumb': 'data:image/jpeg;base64,/9j/old',
        });

        final updated = user.copyWith(
          avatarUrl: '/user/avatar/usr_avatar?v=456',
          clearAvatarBase64: true,
        );

        expect(updated.avatarUrl, '/user/avatar/usr_avatar?v=456');
        expect(updated.avatarBase64, isNull);
      },
    );

    test('email verification resend accepts backend aliases', () {
      final result = EmailVerificationResendResult.fromJson({
        'data': {
          'sent': 'false',
          'email': 'ben@example.com',
          'pending_verification': 'true',
          'expires_in': '300',
          'message': 'Verification code generated',
          'debug_code': '123456',
        },
      });

      expect(result.sent, isFalse);
      expect(result.email, 'ben@example.com');
      expect(result.pendingVerification, isTrue);
      expect(result.expiresIn, 300);
      expect(result.debugCode, '123456');
    });

    test('user service verifies email through backend contract', () async {
      final dio = MockDio()
        ..queueResponse({
          'data': {'verified': true, 'message': 'Email verified successfully'},
        });
      final service = UserService(dio);

      final result = await service.verifyEmail('123456');

      expect(dio.requestHistory.single.method, 'POST');
      expect(dio.requestHistory.single.path, '/user/verify-email');
      expect(dio.requestHistory.single.data, {'code': '123456'});
      expect(result.verified, isTrue);
      expect(result.message, 'Email verified successfully');
    });

    test('email verification result accepts legacy verified aliases', () {
      final result = EmailVerificationResult.fromJson({
        'data': {'emailVerified': 'true'},
      });

      expect(result.verified, isTrue);
    });

    test('normalizes backend KYC approval statuses used by profile gating', () {
      final approvedProfile = UserProfile.fromJson({
        'id': 'usr_approved',
        'kycStatus': 'approved',
      });
      final autoApprovedProfile = UserProfile.fromJson({
        'id': 'usr_auto_approved',
        'kyc_status': 'auto_approved',
      });
      final manualReviewProfile = UserProfile.fromJson({
        'id': 'usr_manual_review',
        'kycStatus': 'manual_review',
      });
      final notStartedProfile = UserProfile.fromJson({
        'id': 'usr_not_started',
        'kycStatus': 'not_started',
      });

      expect(approvedProfile.isKycVerified, isTrue);
      expect(approvedProfile.needsKyc, isFalse);
      expect(autoApprovedProfile.isKycVerified, isTrue);
      expect(autoApprovedProfile.needsKyc, isFalse);
      expect(manualReviewProfile.isKycPending, isTrue);
      expect(manualReviewProfile.needsKyc, isFalse);
      expect(notStartedProfile.isKycVerified, isFalse);
      expect(notStartedProfile.needsKyc, isTrue);
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

    test(
      'user service sends username updates to the profile endpoint',
      () async {
        final dio = MockDio()
          ..queueResponse({
            'data': {'id': 'usr_username', 'username': 'ben_ouattara'},
          });
        final service = UserService(dio);

        final profile = await service.updateProfile(username: 'ben_ouattara');

        expect(dio.requestHistory.single.path, '/user/profile');
        expect(dio.requestHistory.single.data, {'username': 'ben_ouattara'});
        expect(profile.username, 'ben_ouattara');
      },
    );

    test(
      'user service deactivates the account through the backend endpoint',
      () async {
        final dio = MockDio()
          ..queueResponse({'message': 'Account deactivated'});
        final service = UserService(dio);

        await service.deactivateAccount();

        expect(dio.requestHistory.single.method, 'POST');
        expect(dio.requestHistory.single.path, '/user/deactivate');
      },
    );

    test(
      'user avatar upload declares the device face-check contract',
      () async {
        final avatarFile = await _writeTinyJpeg();
        final dio = MockDio()
          ..queueResponse({
            'avatarUrl': '/user/avatar/usr_face_checked',
            'avatarThumb': 'data:image/jpeg;base64,/9j/thumb',
          });
        final service = UserService(dio);

        final avatar = await service.uploadAvatar(
          avatarFile.path,
          faceCheck: AvatarDeviceFaceCheck.fromDeviceAnalysis(
            isAvailable: true,
            faceCount: 1,
          ),
        );

        final formData = dio.requestHistory.single.data as FormData;
        expect(dio.requestHistory.single.path, '/user/avatar');
        expect(formData.files.single.key, 'avatar');
        final evidence = _decodeFaceCheckEvidence(formData);
        final byteSize = await avatarFile.length();
        expect(evidence, containsPair('version', avatarDeviceFaceCheckVersion));
        expect(evidence, containsPair('result', avatarDeviceFaceCheckToken));
        expect(evidence, containsPair('isAvailable', true));
        expect(evidence, containsPair('faceCount', 1));
        expect(evidence['checkedAt'], isA<String>());
        expect(evidence['imageSha256'], matches(RegExp(r'^[a-f0-9]{64}$')));
        expect(evidence, containsPair('byteSize', byteSize));
        expect(avatar.avatarUrl, '/user/avatar/usr_face_checked');
      },
    );

    test('user avatar upload unwraps nested user response envelopes', () async {
      final avatarFile = await _writeTinyJpeg();
      final dio = MockDio()
        ..queueResponse({
          'data': {
            'user': {
              'avatar_url': '/user/avatar/usr_nested',
              'avatarBase64': 'data:image/jpeg;base64,/9j/nested',
            },
          },
        });
      final service = UserService(dio);

      final avatar = await service.uploadAvatar(
        avatarFile.path,
        faceCheck: AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 1,
        ),
      );

      expect(avatar.avatarUrl, '/user/avatar/usr_nested');
      expect(avatar.avatarThumb, startsWith('data:image/jpeg;base64,'));
    });

    test(
      'user avatar upload unwraps nested avatar response envelopes',
      () async {
        final avatarFile = await _writeTinyJpeg();
        final dio = MockDio()
          ..queueResponse({
            'data': {
              'avatar': {
                'avatar_url': '/user/avatar/usr_avatar',
                'avatar_thumb': 'data:image/jpeg;base64,/9j/avatar',
              },
            },
          });
        final service = UserService(dio);

        final avatar = await service.uploadAvatar(
          avatarFile.path,
          faceCheck: AvatarDeviceFaceCheck.fromDeviceAnalysis(
            isAvailable: true,
            faceCount: 1,
          ),
        );

        expect(avatar.avatarUrl, '/user/avatar/usr_avatar');
        expect(avatar.avatarThumb, startsWith('data:image/jpeg;base64,'));
      },
    );
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
      const state = UserState(
        username: 'old_name',
        email: 'old@korido.co',
        emailVerified: true,
      );

      final cleared = state.copyWith(
        username: 'new_name',
        clearEmail: true,
        emailVerified: false,
      );

      expect(cleared.username, 'new_name');
      expect(cleared.email, isNull);
      expect(cleared.emailVerified, isFalse);
    });

    test('secure session profile fields can be explicitly cleared', () {
      final session = UserSession(
        userId: 'usr_001',
        phoneNumber: '+22507080910',
        displayName: 'Old Name',
        firstName: 'Old',
        lastName: 'Name',
        email: 'old@korido.co',
        avatarUrl: '/old/avatar',
        accessToken: 'access',
        refreshToken: 'refresh',
        tokenExpiresAt: DateTime.parse('2026-06-04T10:15:00.000Z'),
        lastActive: DateTime.parse('2026-06-04T10:00:00.000Z'),
        sessionCreatedAt: DateTime.parse('2026-06-04T09:00:00.000Z'),
      );

      final cleared = session.copyWith(
        clearDisplayName: true,
        clearFirstName: true,
        clearLastName: true,
        clearEmail: true,
        clearAvatarUrl: true,
      );

      expect(cleared.displayName, isNull);
      expect(cleared.firstName, isNull);
      expect(cleared.lastName, isNull);
      expect(cleared.email, isNull);
      expect(cleared.avatarUrl, isNull);
      expect(cleared.userId, 'usr_001');
      expect(cleared.accessToken, 'access');
    });

    test('profile snapshots update auth user and persistent session state', () {
      final source = File(
        'lib/features/profile/providers/profile_provider.dart',
      ).readAsStringSync();

      expect(source, contains('auth.authProvider.notifier'));
      expect(source, contains('updateUser(user)'));
      expect(source, contains('userSessionRepositoryProvider'));
      expect(source, contains('clearEmail: profile.email == null'));
      expect(source, contains('clearAvatarUrl: sessionAvatar == null'));
    });

    test('profile provider preserves and explicitly clears errors', () {
      const state = ProfileState(error: 'Upload failed');

      expect(state.copyWith(isUploading: false).error, 'Upload failed');
      expect(state.copyWith(clearError: true).error, isNull);
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
      expect(initStateBody, contains('_hydrateFormFromUserState(userState)'));
      expect(initStateBody, contains('_refreshProfileSnapshot()'));
      expect(source, contains('Future<void> _refreshProfileSnapshot()'));
      expect(source, contains('loadProfile()'));
      expect(source, contains('_selectedImage != null'));
      expect(source, contains('_profilePhotoStatus != null'));
      expect(source, contains('_avatarUrl = userState.avatarUrl'));
      expect(source, contains('_avatarThumb = userState.avatarThumb'));
      expect(source, contains('_profileSaveErrorMessage'));
      expect(source, contains('error is ApiException'));
    });

    test('email verification auto-requests a missing active code once', () {
      final source = File(
        'lib/features/profile/views/email_verification_screen.dart',
      ).readAsStringSync();

      expect(source, contains('_autoRequestedCode'));
      expect(source, contains('!pendingVerification'));
      expect(source, contains('email.isNotEmpty'));
      expect(source, contains('unawaited(_resend())'));
      expect(source, contains("'pending_verification'"));
      expect(source, contains("'expires_in'"));
      expect(source, contains('final normalized = value.toLowerCase()'));
      expect(source, contains("value.replaceAll(RegExp(r'\\D'), '')"));
      expect(source, contains('maxLength: index == 0 ? 6 : 1'));
    });

    test(
      'profile edit prefers uploaded avatar thumbnail for immediate preview',
      () {
        final source = File(
          'lib/features/settings/views/profile_edit_screen.dart',
        ).readAsStringSync();
        final effectiveAvatarBody = RegExp(
          r'String\? get _effectiveAvatarImage \{([\s\S]*?)\n  @override',
        ).firstMatch(source)!.group(1)!;

        expect(
          effectiveAvatarBody.indexOf('return avatarThumb'),
          lessThan(effectiveAvatarBody.indexOf('return avatarUrl')),
          reason:
              'fresh upload thumbnails should render before network avatar URLs',
        );
      },
    );

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
      expect(userStateSource, contains('clearAvatarThumb: clearAvatarThumb'));
      expect(userStateSource, contains("delete(key: 'local_avatar_path')"));
      expect(
        userStateSource,
        contains('ImageCacheConfig.clearCache(ImageCacheType.profilePhoto)'),
      );
      expect(profileProviderSource, contains('await _applyAvatarUploadResult'));
      expect(profileProviderSource, contains('applyServerAvatar('));
      expect(profileProviderSource, contains('clearAvatarThumb: hasAvatarUrl'));
      expect(
        profileProviderSource,
        contains('clearAvatarBase64: hasAvatarUrl'),
      );
      expect(profileProviderSource, contains('auth.authProvider).user'));
      expect(profileProviderSource, contains('updateUser(updatedUser)'));
      expect(profileProviderSource, contains('userSessionRepositoryProvider'));
      expect(profileEditSource, contains('detectFaces(compressed)'));
      expect(profileEditSource, contains('var uploadImage = compressed'));
      expect(profileEditSource, contains('uploadImage = faceCheckImage'));
      expect(
        profileEditSource,
        contains('AvatarDeviceFaceCheck.fromDeviceAnalysis'),
      );
      expect(profileEditSource, contains('Checking face on this device'));
      expect(profileEditSource, contains('_profilePhotoPickErrorMessage'));
      expect(profileEditSource, contains('PlatformException'));
      expect(
        profileEditSource,
        contains('uploadAvatar(uploadImage, faceCheck'),
      );
      expect(profileEditSource, contains('_selectedImage = null'));
    });

    test('avatar widget resolves protected API avatar routes robustly', () {
      final avatarSource = File(
        'lib/design/components/primitives/user_avatar.dart',
      ).readAsStringSync();

      expect(avatarSource, contains("relative.path.startsWith('/api/')"));
      expect(avatarSource, contains("resolvedPath.contains('/user/avatar/')"));
      expect(avatarSource, contains('pathSegments: resolvedSegments'));
      expect(avatarSource, contains('_startsWithSegments'));
      expect(
        avatarSource,
        contains('cacheManager: ImageCacheConfig.profilePhotos'),
      );
    });

    test('profile completion applies backend profile snapshot', () {
      final profileCompleteSource = File(
        'lib/features/onboarding/views/profile_complete_view.dart',
      ).readAsStringSync();

      expect(profileCompleteSource, contains('final profile ='));
      expect(profileCompleteSource, contains('applyProfileSnapshot(profile)'));
      expect(profileCompleteSource, isNot(contains('updateName(')));
    });

    test('avatar device face-check proof is only created for one face', () {
      expect(
        () => AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 0,
        ),
        throwsArgumentError,
      );
      expect(
        () => AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 2,
        ),
        throwsArgumentError,
      );
      expect(
        () => AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: false,
          faceCount: 1,
        ),
        throwsArgumentError,
      );
      expect(
        AvatarDeviceFaceCheck.fromDeviceAnalysis(
          isAvailable: true,
          faceCount: 1,
        ).token,
        contains('"result":"$avatarDeviceFaceCheckToken"'),
      );
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

Map<String, dynamic> _decodeFaceCheckEvidence(FormData formData) {
  final field = formData.fields.singleWhere(
    (entry) => entry.key == avatarDeviceFaceCheckField,
  );
  return jsonDecode(field.value) as Map<String, dynamic>;
}

Future<File> _writeTinyJpeg() async {
  final file = File('${Directory.systemTemp.path}/korido-user-avatar.jpg');
  await file.writeAsBytes(const [
    0xFF,
    0xD8,
    0xFF,
    0xE0,
    0x00,
    0x10,
    0x4A,
    0x46,
    0x49,
    0x46,
    0x00,
    0x01,
    0xFF,
    0xD9,
  ]);
  return file;
}
