import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/enums/index.dart';
import '../services/index.dart';
import '../services/user/user_service.dart';
import 'app_state.dart';
import 'wallet_state_machine.dart';
import 'transaction_state_machine.dart';

/// User/Auth State Machine - manages user authentication globally
class UserStateMachine extends Notifier<UserState> {
  static const _tokenKey = 'access_token';
  static const _phoneKey = 'user_phone';

  @override
  UserState build() {
    // Schedule auth check after provider is fully initialized
    Future.delayed(Duration.zero, _checkStoredAuth);
    return const UserState();
  }

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);
  AuthService get _authService => ref.read(authServiceProvider);
  UserService get _userService => ref.read(userServiceProvider);

  /// Check for stored authentication on app start
  Future<void> _checkStoredAuth() async {
    // Safety check - ensure we're mounted
    try {
      // First update to loading
      state = const UserState(status: AuthStatus.loading);
    } catch (e) {
      // Provider not ready, skip
      return;
    }

    try {
      final token = await _storage.read(key: _tokenKey);
      final phone = await _storage.read(key: _phoneKey);

      if (token != null && token.isNotEmpty) {
        // We have a token, set authenticated state first
        state = UserState(
          status: AuthStatus.authenticated,
          accessToken: token,
          phone: phone,
        );

        // Fetch user profile to populate all user data
        _fetchUserProfile();

        // Trigger wallet and transaction fetch after a small delay
        Future.delayed(const Duration(milliseconds: 100), () {
          try {
            ref.read(walletStateMachineProvider.notifier).fetch();
            ref.read(transactionStateMachineProvider.notifier).fetch();
          } catch (e) {
            // Ignore if providers not ready
          }
        });
      } else {
        state = const UserState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = const UserState(status: AuthStatus.unauthenticated);
    }
  }

  /// Fetch user profile to populate user data
  Future<void> _fetchUserProfile() async {
    try {
      final profile = await _userService.getProfile();

      // Update state with profile data
      state = state.copyWith(
        userId: profile.id,
        phone: profile.phone,
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        avatarUrl: profile.avatarUrl,
        countryCode: profile.countryCode,
        kycStatus: _parseKycStatus(profile.kycStatus),
      );

      // Also update storage with the phone in case it wasn't stored
      await _storage.write(key: _phoneKey, value: profile.phone);
    } catch (e) {
      // Profile fetch failed, but user is still authenticated
      // Don't change auth status
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
      case 'rejected':
        return KycStatus.rejected;
      case 'additional_info_needed':
        return KycStatus.additionalInfoNeeded;
      default:
        print('[KYC] Unknown KYC status: $status, defaulting to none');
        return KycStatus.none;
    }
  }

  /// Request OTP for phone login
  Future<bool> requestOtp(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);

    try {
      await _authService.login(phone: phone);
      state = state.copyWith(status: AuthStatus.otpSent);
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
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
        otp: otp,
      );

      // Store credentials
      await _storage.write(key: _tokenKey, value: response.accessToken);
      await _storage.write(key: _phoneKey, value: state.phone);

      // Reset state machines BEFORE updating auth state to ensure clean slate
      // This prevents any residual data from previous sessions from showing
      ref.read(walletStateMachineProvider.notifier).reset();
      ref.read(transactionStateMachineProvider.notifier).reset();

      // Update state with user info
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: response.user.id,
        phone: response.user.phone,
        firstName: response.user.firstName,
        lastName: response.user.lastName,
        email: response.user.email,
        avatarUrl: response.user.avatarUrl,
        countryCode: response.user.countryCode,
        accessToken: response.accessToken,
        error: null,
      );

      // Trigger wallet and transaction fetch with fresh state
      ref.read(walletStateMachineProvider.notifier).fetch();
      ref.read(transactionStateMachineProvider.notifier).fetch();

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Update user profile
  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? avatarUrl,
    KycStatus? kycStatus,
  }) {
    state = state.copyWith(
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      email: email ?? state.email,
      avatarUrl: avatarUrl ?? state.avatarUrl,
      kycStatus: kycStatus ?? state.kycStatus,
    );
  }

  /// Logout
  Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _phoneKey);

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

final userStateMachineProvider =
    NotifierProvider<UserStateMachine, UserState>(
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
