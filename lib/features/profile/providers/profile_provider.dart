import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/services/user/user_service.dart'
    hide userServiceProvider;
import 'package:usdc_wallet/state/user_state_machine.dart';

/// User profile state.
class ProfileState {
  final User? user;
  final bool isLoading;
  final String? error;
  final bool isUploading;

  const ProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isUploading = false,
  });

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isUploading,
  }) => ProfileState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: error,
    isUploading: isUploading ?? this.isUploading,
  );
}

/// Profile management notifier — wired to UserService.
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true);
    try {
      final service = ref.read(userServiceProvider);
      final profile = await service.getProfile();
      final user = User.fromJson(profile.toJson());
      _syncUserState(profile);
      state = state.copyWith(user: user, isLoading: false, error: null);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to load your profile. Please try again.',
      );
    }
  }

  Future<void> updateDisplayName(String name) async {
    try {
      final service = ref.read(userServiceProvider);
      await service.updateProfile(firstName: name);
      await loadProfile();
    } on ApiException catch (e) {
      state = state.copyWith(error: _friendlyError(e));
    } catch (e) {
      state = state.copyWith(error: 'Unable to update your profile.');
    }
  }

  Future<AvatarUploadResult?> uploadAvatar(File file) async {
    state = state.copyWith(isUploading: true);
    try {
      final service = ref.read(userServiceProvider);
      final result = await service.uploadAvatar(file.path);
      await _applyAvatarUploadResult(result);
      state = state.copyWith(isUploading: false);
      await loadProfile();
      await _applyAvatarUploadResult(result, clearLocalCache: false);
      state = state.copyWith(isUploading: false);
      return result;
    } on ApiException catch (e) {
      state = state.copyWith(isUploading: false, error: _friendlyError(e));
      return null;
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: 'Unable to upload your photo. Please try another image.',
      );
      return null;
    }
  }

  Future<void> applyProfileSnapshot(
    UserProfile profile, {
    String? avatarUrl,
    String? avatarThumb,
    bool avatarChanged = false,
  }) async {
    final mergedProfile = UserProfile.fromJson({
      ...profile.toJson(),
      'avatarUrl': avatarUrl ?? profile.avatarUrl,
      'avatarThumb': avatarThumb ?? profile.avatarThumb,
    });

    _syncUserState(mergedProfile);
    if (avatarChanged) {
      await _applyAvatarUploadResult(
        AvatarUploadResult(avatarUrl: avatarUrl, avatarThumb: avatarThumb),
      );
    }
    state = state.copyWith(
      user: User.fromJson(mergedProfile.toJson()),
      isLoading: false,
      isUploading: false,
      error: null,
    );
  }

  Future<void> removeAvatar() async {
    try {
      final service = ref.read(userServiceProvider);
      await service.removeAvatar();
      await ref.read(userStateMachineProvider.notifier).clearAvatar();
      await loadProfile();
    } on ApiException catch (e) {
      state = state.copyWith(error: _friendlyError(e));
    } catch (e) {
      state = state.copyWith(error: 'Unable to remove your photo.');
    }
  }

  Future<void> updateLocale(String locale) async {
    try {
      final service = ref.read(userServiceProvider);
      await service.updateLocale(locale);
    } on ApiException catch (e) {
      state = state.copyWith(error: _friendlyError(e));
    } catch (e) {
      state = state.copyWith(error: 'Unable to update your language.');
    }
  }

  void _syncUserState(UserProfile profile) {
    ref
        .read(userStateMachineProvider.notifier)
        .updateProfile(
          firstName: profile.firstName,
          lastName: profile.lastName,
          email: profile.email,
          emailVerified: profile.emailVerified,
          clearEmail: profile.email == null || profile.email!.isEmpty,
          avatarUrl: profile.avatarUrl,
          avatarThumb: profile.avatarThumb,
          clearAvatarUrl:
              profile.avatarUrl == null || profile.avatarUrl!.isEmpty,
          clearAvatarThumb:
              profile.avatarThumb == null || profile.avatarThumb!.isEmpty,
        );
  }

  Future<void> _applyAvatarUploadResult(
    AvatarUploadResult result, {
    bool clearLocalCache = true,
  }) async {
    final hasAvatarUrl =
        result.avatarUrl != null && result.avatarUrl!.isNotEmpty;
    final hasAvatarThumb =
        result.avatarThumb != null && result.avatarThumb!.isNotEmpty;
    if (!hasAvatarUrl && !hasAvatarThumb) {
      return;
    }

    await ref
        .read(userStateMachineProvider.notifier)
        .applyServerAvatar(
          avatarUrl: result.avatarUrl,
          avatarThumb: result.avatarThumb,
          clearLocalCache: clearLocalCache,
        );

    final currentUser = state.user;
    if (currentUser != null) {
      state = state.copyWith(
        user: currentUser.copyWith(
          avatarUrl: hasAvatarUrl ? result.avatarUrl : currentUser.avatarUrl,
          avatarBase64: hasAvatarThumb
              ? result.avatarThumb
              : currentUser.avatarBase64,
        ),
      );
    }
  }

  String _friendlyError(ApiException error) {
    if (error.isDeviceBlacklisted) {
      return error.message;
    }
    if (error.statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }
    if (error.statusCode == 413) {
      return 'This image is too large. Please choose a smaller photo.';
    }
    return error.message;
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
