import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/services/index.dart';

/// Profile State
class ProfileState {
  final User? user;
  final String? avatarUrl;
  final bool isLoading;
  final String? error;
  final bool isUploadingAvatar;

  const ProfileState({
    this.user,
    this.avatarUrl,
    this.isLoading = false,
    this.error,
    this.isUploadingAvatar = false,
  });

  ProfileState copyWith({
    User? user,
    String? avatarUrl,
    bool? isLoading,
    String? error,
    bool? isUploadingAvatar,
  }) {
    return ProfileState(
      user: user ?? this.user,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar,
    );
  }

  /// Helper getters
  bool get hasUser => user != null;
  bool get hasAvatar => avatarUrl != null && avatarUrl!.isNotEmpty;
  String get displayName => user?.displayName ?? '';
  String get fullName => user?.fullName ?? '';
}

/// Profile Notifier
class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    // Initialize with auth user if available
    final authState = ref.watch(authProvider);
    return ProfileState(
      user: authState.user,
      avatarUrl: authState.user?.avatarUrl,
    );
  }

  UserService get _userService => ref.read(userServiceProvider);
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  /// Load full profile from backend
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _userService.getProfile();

      // Convert UserProfile to User entity
      final user = User(
        id: profile.id,
        phone: profile.phone,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        avatarUrl: profile.avatarUrl,
        countryCode: profile.countryCode,
        isPhoneVerified: profile.phoneVerified,
        role: UserRole.values.firstWhere(
          (e) => e.name == profile.role,
          orElse: () => UserRole.user,
        ),
        status: UserStatus.values.firstWhere(
          (e) => e.name == profile.status,
          orElse: () => UserStatus.active,
        ),
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt ?? DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
        avatarUrl: profile.avatarUrl,
      );

      // Update auth provider with fresh user data
      ref.read(authProvider.notifier).updateUser(user);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Update profile information
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final profile = await _userService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      // Convert UserProfile to User entity
      final user = User(
        id: profile.id,
        phone: profile.phone,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        avatarUrl: profile.avatarUrl,
        countryCode: profile.countryCode,
        isPhoneVerified: profile.phoneVerified,
        role: UserRole.values.firstWhere(
          (e) => e.name == profile.role,
          orElse: () => UserRole.user,
        ),
        status: UserStatus.values.firstWhere(
          (e) => e.name == profile.status,
          orElse: () => UserStatus.active,
        ),
        createdAt: profile.createdAt,
        updatedAt: profile.updatedAt ?? DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        user: user,
        avatarUrl: profile.avatarUrl,
      );

      // Update auth provider
      ref.read(authProvider.notifier).updateUser(user);

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Upload avatar image
  /// Accepts a File object (from image picker)
  Future<bool> updateAvatar(File imageFile) async {
    state = state.copyWith(isUploadingAvatar: true, error: null);

    try {
      final profile = await _userService.uploadAvatar(imageFile.path);

      // Update local state
      final updatedUser = state.user?.copyWith(avatarUrl: profile.avatarUrl);

      state = state.copyWith(
        isUploadingAvatar: false,
        avatarUrl: profile.avatarUrl,
        user: updatedUser,
      );

      // Update auth provider
      if (updatedUser != null) {
        ref.read(authProvider.notifier).updateUser(updatedUser);
      }

      // Cache avatar URL in secure storage for offline access
      if (profile.avatarUrl != null) {
        await _storage.write(
          key: StorageKeys.avatarUrl,
          value: profile.avatarUrl!,
        );
      }

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isUploadingAvatar: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isUploadingAvatar: false, error: e.toString());
      return false;
    }
  }

  /// Remove avatar
  Future<bool> removeAvatar() async {
    state = state.copyWith(isUploadingAvatar: true, error: null);

    try {
      await _userService.removeAvatar();

      // Update local state
      final updatedUser = state.user?.copyWith(avatarUrl: null);

      state = state.copyWith(
        isUploadingAvatar: false,
        avatarUrl: null,
        user: updatedUser,
      );

      // Update auth provider
      if (updatedUser != null) {
        ref.read(authProvider.notifier).updateUser(updatedUser);
      }

      // Remove cached avatar URL
      await _storage.delete(key: StorageKeys.avatarUrl);

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isUploadingAvatar: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(isUploadingAvatar: false, error: e.toString());
      return false;
    }
  }

  /// Get avatar URL from backend or local cache
  Future<String?> getAvatarUrl() async {
    // Try to get from backend first
    try {
      final url = await _userService.getAvatarUrl();
      if (url != null) {
        state = state.copyWith(avatarUrl: url);
        // Cache it
        await _storage.write(key: StorageKeys.avatarUrl, value: url);
      }
      return url;
    } catch (e) {
      // Fallback to cached version
      final cached = await _storage.read(key: StorageKeys.avatarUrl);
      if (cached != null) {
        state = state.copyWith(avatarUrl: cached);
      }
      return cached;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh profile (pull to refresh)
  Future<void> refresh() async {
    await loadProfile();
  }
}

/// Profile Provider
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
