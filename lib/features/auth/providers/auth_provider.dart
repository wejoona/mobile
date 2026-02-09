import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/index.dart';
import '../../../domain/entities/index.dart';
import '../../../state/fsm/index.dart';
import '../../../state/kyc_state_machine.dart';

/// Auth State
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  otpSent,
  error,
}

class AuthState {
  final AuthStatus status;
  final User? user;
  final String? phone;
  final String? error;
  final int? otpExpiresIn;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.phone,
    this.error,
    this.otpExpiresIn,
  });

  AuthState copyWith({
    AuthStatus? status,
    User? user,
    String? phone,
    String? error,
    int? otpExpiresIn,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      phone: phone ?? this.phone,
      error: error,
      otpExpiresIn: otpExpiresIn ?? this.otpExpiresIn,
    );
  }

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;
}

/// Auth Notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  AuthService get _authService => ref.read(authServiceProvider);
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  /// Check if user is already authenticated
  Future<void> checkAuth() async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final token = await _storage.read(key: StorageKeys.accessToken);

      if (token != null) {
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Register new user
  Future<void> register(String phone, String countryCode) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);

    // Sync with FSM: notify that login/register is starting
    ref.read(appFsmProvider.notifier).login(phone, countryCode);

    try {
      final response = await _authService.register(
        phone: phone,
        countryCode: countryCode,
      );

      state = state.copyWith(
        status: AuthStatus.otpSent,
        otpExpiresIn: response.expiresIn,
      );

      // Sync with FSM: notify that OTP was sent
      ref.read(appFsmProvider.notifier).onOtpReceived(expiresIn: response.expiresIn);
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);

      // Sync with FSM: notify auth failed
      ref.read(appFsmProvider.notifier).onAuthFailed(e.message);
    }
  }

  /// Login existing user
  Future<void> login(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);

    // Sync with FSM: notify that login is starting
    // Note: Using empty country code since login doesn't require it
    ref.read(appFsmProvider.notifier).login(phone, '');

    try {
      final response = await _authService.login(phone: phone);

      state = state.copyWith(
        status: AuthStatus.otpSent,
        otpExpiresIn: response.expiresIn,
      );

      // Sync with FSM: notify that OTP was sent
      ref.read(appFsmProvider.notifier).onOtpReceived(expiresIn: response.expiresIn);
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);

      // Sync with FSM: notify auth failed
      ref.read(appFsmProvider.notifier).onAuthFailed(e.message);
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    if (state.phone == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Phone number not found',
      );
      return false;
    }

    state = state.copyWith(status: AuthStatus.loading);

    // Sync with FSM: notify that OTP verification is starting
    ref.read(appFsmProvider.notifier).verifyOtp(otp);

    try {
      final response = await _authService.verifyOtp(
        phone: state.phone!,
        otp: otp,
      );

      // Store tokens
      await _storage.write(
        key: StorageKeys.accessToken,
        value: response.accessToken,
      );

      // Store refresh token if provided for biometric login on next session
      if (response.refreshToken != null) {
        await _storage.write(
          key: StorageKeys.refreshToken,
          value: response.refreshToken!,
        );
      }

      // Start session with actual token validity from backend
      await ref.read(sessionServiceProvider.notifier).startSession(
        accessToken: response.accessToken,
        tokenValidity: Duration(seconds: response.expiresIn),
      );

      // Sync with FSM: notify that auth verification succeeded
      // Do this BEFORE setting authenticated status to ensure wallet fetch is queued
      ref.read(appFsmProvider.notifier).onAuthVerified(
        userId: response.user.id,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      // Also report KYC status from the auth response to avoid waiting for separate fetch
      // This ensures the FSM knows the KYC state immediately
      if (response.kycStatus != null) {
        ref.read(kycStateMachineProvider.notifier).updateFromAuthResponse(response.kycStatus);
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );

      return true;
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);

      // Sync with FSM: notify auth failed
      ref.read(appFsmProvider.notifier).onAuthFailed(e.message);
      return false;
    } catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.toString());

      // Sync with FSM: notify auth failed
      ref.read(appFsmProvider.notifier).onAuthFailed(e.toString());
      return false;
    }
  }

  /// Login with biometric (refresh token)
  Future<bool> loginWithBiometric(String refreshToken) async {
    state = state.copyWith(status: AuthStatus.loading);

    try {
      final response = await _authService.refreshToken(refreshToken: refreshToken);

      // Store new tokens
      await _storage.write(
        key: StorageKeys.accessToken,
        value: response.accessToken,
      );
      if (response.refreshToken != null) {
        await _storage.write(
          key: StorageKeys.refreshToken,
          value: response.refreshToken!,
        );
      }

      // Start session with actual token validity from backend
      await ref.read(sessionServiceProvider.notifier).startSession(
        accessToken: response.accessToken,
        tokenValidity: Duration(seconds: response.expiresIn),
      );

      // Sync with FSM: notify that auth verification succeeded
      ref.read(appFsmProvider.notifier).onAuthVerified(
        userId: response.user?.id ?? '',
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );

      return true;
    } catch (e) {
      // Clear invalid refresh token
      await _storage.delete(key: StorageKeys.refreshToken);
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Biometric login failed. Please log in again.',
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    // End session first
    await ref.read(sessionServiceProvider.notifier).endSession();

    await _storage.delete(key: StorageKeys.accessToken);
    await _storage.delete(key: StorageKeys.refreshToken);

    state = const AuthState(status: AuthStatus.unauthenticated);

    // Sync with FSM: notify logout
    ref.read(appFsmProvider.notifier).logout();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update user data (called from profile updates)
  void updateUser(User user) {
    state = state.copyWith(user: user);
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
