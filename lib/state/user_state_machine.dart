import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../domain/enums/index.dart';
import '../services/index.dart';
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
        // We have a token, try to validate it
        state = UserState(
          status: AuthStatus.authenticated,
          accessToken: token,
          phone: phone,
        );

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

      // Update state with user info
      state = state.copyWith(
        status: AuthStatus.authenticated,
        userId: response.user.id,
        phone: response.user.phone,
        firstName: response.user.firstName,
        lastName: response.user.lastName,
        email: response.user.email,
        countryCode: response.user.countryCode,
        accessToken: response.accessToken,
        error: null,
      );

      // Trigger wallet and transaction fetch
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
    KycStatus? kycStatus,
  }) {
    state = state.copyWith(
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      email: email ?? state.email,
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
