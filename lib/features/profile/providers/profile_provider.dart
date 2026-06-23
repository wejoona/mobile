import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/user.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/services/api/api_client.dart';
import 'package:usdc_wallet/services/service_providers.dart';
import 'package:usdc_wallet/services/session/user_session_repository.dart';
import 'package:usdc_wallet/services/user/avatar_multipart.dart';
import 'package:usdc_wallet/services/user/user_service.dart'
    hide userServiceProvider;
import 'package:usdc_wallet/state/user_state_machine.dart';

/// User profile state.
class ProfileState {
  const ProfileState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isUploading = false,
  });

  final User? user;
  final bool isLoading;
  final String? error;
  final bool isUploading;

  ProfileState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isUploading,
    bool clearError = false,
  }) => ProfileState(
    user: user ?? this.user,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
    isUploading: isUploading ?? this.isUploading,
  );
}

/// Profile management notifier — wired to UserService.
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() => const ProfileState();

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final service = ref.read(userServiceProvider);
      final profile = await service.getProfile();
      final user = User.fromJson(profile.toJson());
      await _syncUserState(profile);
      state = state.copyWith(user: user, isLoading: false, clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    } on Object {
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
    } on Object {
      state = state.copyWith(error: 'Unable to update your profile.');
    }
  }

  Future<AvatarUploadResult?> uploadAvatar(
    File file, {
    required AvatarDeviceFaceCheck faceCheck,
  }) async {
    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final service = ref.read(userServiceProvider);
      final result = await service.uploadAvatar(
        file.path,
        faceCheck: faceCheck,
      );
      await _applyAvatarUploadResult(result);
      await loadProfile();
      await _applyAvatarUploadResult(result, clearLocalCache: false);
      state = state.copyWith(isUploading: false, clearError: true);
      return result;
    } on ApiException catch (e) {
      state = state.copyWith(isUploading: false, error: _friendlyError(e));
      return null;
    } on Object {
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
    final currentUserState = ref.read(userStateMachineProvider);
    final effectiveAvatarUrl =
        avatarUrl ?? profile.avatarUrl ?? currentUserState.avatarUrl;
    final effectiveAvatarThumb =
        avatarThumb ?? profile.avatarThumb ?? currentUserState.avatarThumb;
    final mergedProfile = UserProfile.fromJson({
      ...profile.toJson(),
      'avatarUrl': effectiveAvatarUrl,
      'avatarThumb': effectiveAvatarThumb,
    });

    await _syncUserState(mergedProfile);
    if (avatarChanged) {
      await _applyAvatarUploadResult(
        AvatarUploadResult(avatarUrl: avatarUrl, avatarThumb: avatarThumb),
      );
    }
    state = state.copyWith(
      user: User.fromJson(mergedProfile.toJson()),
      isLoading: false,
      isUploading: false,
      clearError: true,
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
    } on Object {
      state = state.copyWith(error: 'Unable to remove your photo.');
    }
  }

  Future<void> updateLocale(String locale) async {
    try {
      final service = ref.read(userServiceProvider);
      await service.updateLocale(locale);
      state = state.copyWith(clearError: true);
    } on ApiException catch (e) {
      state = state.copyWith(error: _friendlyError(e));
    } on Object {
      state = state.copyWith(error: 'Unable to update your language.');
    }
  }

  Future<void> _syncUserState(UserProfile profile) async {
    ref
        .read(userStateMachineProvider.notifier)
        .updateProfile(
          firstName: profile.firstName,
          lastName: profile.lastName,
          username: profile.username,
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

    final user = User.fromJson(profile.toJson());
    ref.read(auth.authProvider.notifier).updateUser(user);

    final sessionAvatar = (profile.avatarThumb?.isNotEmpty ?? false)
        ? profile.avatarThumb
        : profile.avatarUrl;
    await ref
        .read(userSessionRepositoryProvider)
        .updateProfile(
          displayName: profile.displayName.isNotEmpty
              ? profile.displayName
              : null,
          firstName: profile.firstName,
          lastName: profile.lastName,
          email: profile.email,
          avatarUrl: sessionAvatar,
          kycStatus: profile.kycStatus,
          hasCompletedKyc: profile.isKycVerified,
          clearDisplayName: profile.displayName.isEmpty,
          clearFirstName:
              profile.firstName == null || profile.firstName!.isEmpty,
          clearLastName: profile.lastName == null || profile.lastName!.isEmpty,
          clearEmail: profile.email == null || profile.email!.isEmpty,
          clearAvatarUrl: sessionAvatar == null || sessionAvatar.isEmpty,
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
          clearAvatarThumb: hasAvatarUrl && !hasAvatarThumb,
          clearLocalCache: clearLocalCache,
        );

    final currentUser = state.user ?? ref.read(auth.authProvider).user;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(
        avatarUrl: hasAvatarUrl ? result.avatarUrl : currentUser.avatarUrl,
        avatarBase64: hasAvatarThumb
            ? result.avatarThumb
            : currentUser.avatarBase64,
        clearAvatarBase64: hasAvatarUrl && !hasAvatarThumb,
      );
      state = state.copyWith(user: updatedUser);
      ref.read(auth.authProvider.notifier).updateUser(updatedUser);
    }

    final sessionAvatar = hasAvatarThumb
        ? result.avatarThumb
        : result.avatarUrl;
    await ref
        .read(userSessionRepositoryProvider)
        .updateProfile(
          avatarUrl: sessionAvatar,
          clearAvatarUrl: sessionAvatar == null || sessionAvatar.isEmpty,
        );
  }

  String _friendlyError(ApiException error) {
    if (error.isDeviceBlacklisted) {
      return error.message;
    }
    if (error.statusCode == 401) {
      return 'Your session has expired. Please sign in again.';
    }
    final normalizedMessage = error.message.toLowerCase();
    if (error.statusCode == 400 &&
        (normalizedMessage.contains('single-face device check') ||
            normalizedMessage.contains('profile photo must pass'))) {
      return 'We could not verify this photo securely. Please choose a clear selfie with only your face visible and try again.';
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
