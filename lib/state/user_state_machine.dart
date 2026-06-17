import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/state/kyc_state_machine.dart';
import 'package:usdc_wallet/services/avatar/avatar_cache_service.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// User/Auth State Machine - manages user authentication globally
class UserStateMachine extends Notifier<UserState> {
  static const _tokenKey = StorageKeys.accessToken;
  static const _phoneKey = StorageKeys.userPhone;

  @override
  UserState build() {
    final storage = ref.read(secureStorageProvider);

    // Schedule auth check after provider is fully initialized
    Future.delayed(Duration.zero, () => _checkStoredAuth(storage));
    return const UserState();
  }

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);
  AuthService get _authService => ref.read(authServiceProvider);
  UserService get _userService => ref.read(userServiceProvider);

  Future<PhoneNumberValue?> _persistPhoneValue(
    FlutterSecureStorage storage, {
    required String? phone,
    String? countryCode,
  }) async {
    final phoneValue = PhoneNumberValue.tryFromAny(
      phoneNumber: phone,
      countryCode: countryCode,
    );
    if (phoneValue == null) {
      return null;
    }

    await storage.write(key: _phoneKey, value: phoneValue.e164);
    await storage.write(key: StorageKeys.userPhoneE164, value: phoneValue.e164);
    await storage.write(
      key: StorageKeys.userDialCode,
      value: phoneValue.dialCode,
    );
    await storage.write(
      key: StorageKeys.userLocalPhone,
      value: phoneValue.localNumber,
    );

    return phoneValue;
  }

  Future<PhoneNumberValue?> _readStoredPhoneValue(
    FlutterSecureStorage storage,
  ) async {
    final storedDialCode = await storage.read(key: StorageKeys.userDialCode);
    final storedLocalPhone = await storage.read(
      key: StorageKeys.userLocalPhone,
    );
    final storedParts = storedDialCode != null && storedLocalPhone != null
        ? PhoneNumberValue.tryFromAny(
            phoneNumber: storedLocalPhone,
            countryCode: storedDialCode,
          )
        : null;
    if (storedParts != null) {
      return storedParts;
    }

    final storedE164 = await storage.read(key: StorageKeys.userPhoneE164);
    final storedE164Value = PhoneNumberValue.tryFromAny(
      phoneNumber: storedE164,
    );
    if (storedE164Value != null) {
      return storedE164Value;
    }

    final legacyStoredPhone = await storage.read(key: _phoneKey);
    return PhoneNumberValue.tryFromAny(phoneNumber: legacyStoredPhone);
  }

  /// Check for stored authentication on app start
  Future<void> _checkStoredAuth(FlutterSecureStorage storage) async {
    // Safety check - ensure we're mounted
    if (!ref.mounted) return;
    try {
      // First update to loading
      state = const UserState(status: AuthStatus.loading);
    } catch (e) {
      // Provider not ready, skip
      return;
    }

    try {
      // Debug auto-login: if a token is passed via --dart-define, use it
      const debugToken = String.fromEnvironment('DEBUG_TOKEN');
      const debugPhone = String.fromEnvironment('DEBUG_PHONE');
      if (debugToken.isNotEmpty) {
        await storage.write(key: _tokenKey, value: debugToken);
        if (debugPhone.isNotEmpty) {
          await _persistPhoneValue(storage, phone: debugPhone);
        }
        debugPrint('[DEBUG] Auto-login token injected');
      }

      final token = await storage.read(key: _tokenKey);
      final phoneValue = await _readStoredPhoneValue(storage);
      if (!ref.mounted) return;

      if (token != null && token.isNotEmpty) {
        _loadCachedProfile();
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          accessToken: token,
          phone: phoneValue?.localNumber,
          countryCode: phoneValue?.isoCountryCode,
        );
      } else {
        state = const UserState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = const UserState(status: AuthStatus.unauthenticated);
    }
  }

  /// Hydrate profile and related authenticated resources after primary auth
  /// confirms the session is usable.
  Future<void> hydrateAuthenticatedSession({bool fetchRelated = true}) async {
    final token = await _storage.read(key: _tokenKey);
    final phoneValue = await _readStoredPhoneValue(_storage);
    if (!ref.mounted) return;

    if (token == null || token.isEmpty) {
      state = const UserState(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      // Load local avatar immediately (before network call)
      String? localAvatar;
      final savedAvatar = await _storage.read(key: 'local_avatar_path');
      if (savedAvatar != null && await File(savedAvatar).exists()) {
        localAvatar = savedAvatar;
      }
      if (!ref.mounted) return;

      // We have a token, set authenticated state first
      state = UserState(
        status: AuthStatus.authenticated,
        accessToken: token,
        phone: phoneValue?.localNumber,
        countryCode: phoneValue?.isoCountryCode ?? 'CI',
        avatarUrl: localAvatar,
      );

      // Immediately load cached profile so name/data show while network loads
      _loadCachedProfile();

      // Fetch user profile from server (will update with fresh data)
      await _fetchUserProfile();
      if (!ref.mounted) return;

      // Trigger wallet, KYC, and transaction fetch after a small delay
      if (fetchRelated) {
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!ref.mounted) return;
          try {
            ref.read(walletStateMachineProvider.notifier).fetch();
            ref.read(kycStateMachineProvider.notifier).fetch();
            ref.read(transactionStateMachineProvider.notifier).fetch();
          } catch (e) {
            // Ignore if providers not ready
          }
        });
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
    }
  }

  /// Fetch user profile to populate user data
  Future<void> _fetchUserProfile() async {
    try {
      final profile = await _userService.getProfile();
      if (!ref.mounted) return;

      final hasServerAvatar =
          profile.avatarUrl != null && profile.avatarUrl!.isNotEmpty;
      final hasAvatarThumb =
          profile.avatarThumb != null && profile.avatarThumb!.isNotEmpty;

      final phoneValue = await _persistPhoneValue(
        _storage,
        phone: profile.phone,
        countryCode: profile.countryCode,
      );

      // Update state with profile data
      state = state.copyWith(
        userId: profile.id,
        phone: phoneValue?.localNumber ?? profile.phone,
        username: profile.username,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        emailVerified: profile.emailVerified,
        avatarUrl: profile.avatarUrl,
        avatarThumb: profile.avatarThumb,
        clearAvatarUrl: !hasServerAvatar,
        clearAvatarThumb: !hasAvatarThumb,
        countryCode: profile.countryCode,
        kycStatus: _parseKycStatus(profile.kycStatus),
        canTransact: profile.canTransact,
        canWithdraw: profile.canWithdraw,
      );

      // Cache user profile locally
      ref.read(localSyncServiceProvider).cacheUserFromState(state);

      final serverAvatarUrl = profile.avatarUrl;
      final isProtectedServerAvatar = _isProtectedRelativeAvatarUrl(
        serverAvatarUrl,
      );

      // Cache only public avatar URLs. The API's /user/avatar/:id route is
      // bearer-protected, so UI should render avatarThumb instead.
      if (hasServerAvatar && !isProtectedServerAvatar) {
        final cached = await ref
            .read(avatarCacheServiceProvider)
            .cacheAvatar(serverAvatarUrl!);
        if (cached != null) {
          await _storage.write(key: 'local_avatar_path', value: cached);
          state = state.copyWith(avatarUrl: cached);
        }
      } else if (!hasServerAvatar && !hasAvatarThumb) {
        await clearAvatar();
      } else if (isProtectedServerAvatar) {
        await _storage.delete(key: 'local_avatar_path');
      }
    } on ApiException catch (e) {
      debugPrint(
        '[UserState] Profile fetch failed: ${e.statusCode} ${e.message}',
      );
      // 401/403 are handled by the Dio AuthInterceptor (refresh + retry + FSM logout)
      // Don't double-logout here — just fall back to cache for non-auth errors
      if (e.statusCode != 401 && e.statusCode != 403) {
        _loadCachedProfile();
      }
      // For 401/403: interceptor already triggered FSM logout, don't interfere
    } catch (e) {
      debugPrint('[UserState] Profile fetch error: $e');
      // Network/timeout errors: try loading from cache
      _loadCachedProfile();
    }
  }

  /// Load user profile from local Hive cache (offline fallback)
  void _loadCachedProfile() {
    try {
      final sync = ref.read(localSyncServiceProvider);
      final cached = sync.getCachedUserProfile();
      if (cached != null) {
        debugPrint(
          '[UserState] Loaded cached profile: ${cached.firstName} ${cached.lastName}',
        );
        state = state.copyWith(
          userId: cached.userId,
          username: cached.username,
          firstName: cached.firstName,
          lastName: cached.lastName,
          email: cached.email,
          avatarUrl: cached.avatarUrl,
          avatarThumb: cached.avatarThumb,
          clearAvatarUrl: cached.avatarUrl == null || cached.avatarUrl!.isEmpty,
          clearAvatarThumb:
              cached.avatarThumb == null || cached.avatarThumb!.isEmpty,
          countryCode: cached.countryCode,
        );
      }
    } catch (e) {
      debugPrint('[UserState] Cache load failed: $e');
    }
  }

  KycStatus _parseKycStatus(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
      case 'approved':
      case 'auto_approved':
        return KycStatus.verified;
      case 'pending':
        return KycStatus.pending;
      case 'documents_pending':
        return KycStatus.documentsPending;
      case 'submitted':
      case 'in_review':
      case 'pending_verification':
        return KycStatus.submitted;
      case 'manual_review':
        return KycStatus.manualReview;
      case 'rejected':
        return KycStatus.rejected;
      case 'additional_info_needed':
        return KycStatus.additionalInfoNeeded;
      default:
        debugPrint('[KYC] Unknown KYC status: $status, defaulting to none');
        return KycStatus.none;
    }
  }

  bool _isProtectedRelativeAvatarUrl(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return value.startsWith('/user/avatar/');
  }

  /// Request OTP for phone login
  Future<bool> requestOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);

    try {
      await _authService.login(phone: phone);
      state = state.copyWith(status: AuthStatus.otpSent);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  /// Verify OTP and complete login
  Future<bool> verifyOtp(String otp) async {
    if (state.phone == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Phone number not set',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.verifyOtp(
        phone: state.phone!,
        countryCode: state.countryCode,
        otp: otp,
      );

      // Store credentials
      await _storage.write(key: _tokenKey, value: response.accessToken);
      final phoneValue = await _persistPhoneValue(
        _storage,
        phone: response.user.phone.isNotEmpty
            ? response.user.phone
            : state.phone,
        countryCode: response.user.countryCode,
      );

      // Reset state machines BEFORE updating auth state to ensure clean slate
      // This prevents any residual data from previous sessions from showing
      ref.read(walletStateMachineProvider.notifier).reset();
      ref.read(transactionStateMachineProvider.notifier).reset();

      // Update state with user info
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: response.user.id,
        phone: phoneValue?.localNumber ?? response.user.phone,
        username: response.user.username,
        firstName: response.user.firstName,
        lastName: response.user.lastName,
        email: response.user.email,
        avatarUrl: response.user.avatarUrl,
        avatarThumb: response.user.avatarBase64,
        countryCode: response.user.countryCode,
        accessToken: response.accessToken,
        error: null,
      );

      // Trigger wallet and transaction fetch with fresh state
      ref.read(walletStateMachineProvider.notifier).fetch();
      ref.read(transactionStateMachineProvider.notifier).fetch();

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
      return false;
    }
  }

  /// Update user profile
  void updateProfile({
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    bool? emailVerified,
    String? avatarUrl,
    String? avatarThumb,
    KycStatus? kycStatus,
    bool clearEmail = false,
    bool clearAvatarUrl = false,
    bool clearAvatarThumb = false,
  }) {
    state = state.copyWith(
      username: username ?? state.username,
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      email: email ?? state.email,
      emailVerified: emailVerified ?? state.emailVerified,
      clearEmail: clearEmail,
      avatarUrl: avatarUrl ?? state.avatarUrl,
      avatarThumb: avatarThumb ?? state.avatarThumb,
      clearAvatarUrl: clearAvatarUrl,
      clearAvatarThumb: clearAvatarThumb,
      kycStatus: kycStatus ?? state.kycStatus,
    );
    ref.read(localSyncServiceProvider).cacheUserFromState(state);
  }

  /// Apply a freshly uploaded server avatar and discard stale local files.
  Future<void> applyServerAvatar({
    String? avatarUrl,
    String? avatarThumb,
    bool clearAvatarThumb = false,
    bool clearLocalCache = true,
  }) async {
    final hasAvatarUrl = avatarUrl != null && avatarUrl.isNotEmpty;
    final hasAvatarThumb = avatarThumb != null && avatarThumb.isNotEmpty;
    if (!hasAvatarUrl && !hasAvatarThumb) {
      return;
    }

    if (clearLocalCache) {
      await _clearLocalAvatarCache();
    }

    updateProfile(
      avatarUrl: avatarUrl,
      avatarThumb: avatarThumb,
      clearAvatarThumb: clearAvatarThumb,
    );
  }

  /// Clear all avatar references after the backend confirms removal.
  Future<void> clearAvatar() async {
    await _clearLocalAvatarCache();

    state = state.copyWith(clearAvatarUrl: true, clearAvatarThumb: true);
    ref.read(localSyncServiceProvider).cacheUserFromState(state);
  }

  Future<void> _clearLocalAvatarCache() async {
    final localAvatar = await _storage.read(key: 'local_avatar_path');
    if (localAvatar != null) {
      final file = File(localAvatar);
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }

    await _storage.delete(key: 'local_avatar_path');
    await ref.read(avatarCacheServiceProvider).clearCache();
  }

  /// Logout
  /// Update user's name (e.g. after KYC submission)
  void updateName({required String firstName, required String lastName}) {
    state = state.copyWith(firstName: firstName, lastName: lastName);
  }

  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _phoneKey);
    await _storage.delete(key: 'local_avatar_path');

    // Clear local cache
    await ref.read(localSyncServiceProvider).clearOnLogout();

    // Clear avatar cache
    ref.read(avatarCacheServiceProvider).clearCache();

    // Reset all state machines
    ref.read(walletStateMachineProvider.notifier).reset();
    ref.read(transactionStateMachineProvider.notifier).reset();

    state = const UserState(status: AuthStatus.unauthenticated);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Reset to OTP sent state (for resending OTP)
  void resetToOtpSent() {
    state = state.copyWith(status: AuthStatus.otpSent, error: null);
  }
}

final userStateMachineProvider = NotifierProvider<UserStateMachine, UserState>(
  UserStateMachine.new,
);

/// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(userStateMachineProvider).isAuthenticated;
});

final userPhoneProvider = Provider<String?>((ref) {
  return ref.watch(userStateMachineProvider).phone;
});

final userDisplayNameProvider = Provider<String>((ref) {
  return ref.watch(userStateMachineProvider).displayName;
});

final kycStatusProvider = Provider<KycStatus>((ref) {
  return ref.watch(userStateMachineProvider).kycStatus;
});

final canTransactProvider = Provider<bool>((ref) {
  return ref.watch(userStateMachineProvider).canTransact;
});
