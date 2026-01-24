import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/index.dart';
import '../../../services/session/session_service.dart';
import '../../../domain/entities/index.dart';

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

    try {
      final response = await _authService.register(
        phone: phone,
        countryCode: countryCode,
      );

      state = state.copyWith(
        status: AuthStatus.otpSent,
        otpExpiresIn: response.expiresIn,
      );
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
    }
  }

  /// Login existing user
  Future<void> login(String phone) async {
    state = state.copyWith(status: AuthStatus.loading, phone: phone);

    try {
      final response = await _authService.login(phone: phone);

      state = state.copyWith(
        status: AuthStatus.otpSent,
        otpExpiresIn: response.expiresIn,
      );
    } on ApiException catch (e) {
      state = state.copyWith(status: AuthStatus.error, error: e.message);
    }
  }

  /// Verify OTP
  Future<bool> verifyOtp(String otp) async {
    debugPrint('verifyOtp called with otp: $otp');

    if (state.phone == null) {
      debugPrint('ERROR: Phone number not found in state');
      state = state.copyWith(
        status: AuthStatus.error,
        error: 'Phone number not found',
      );
      return false;
    }

    debugPrint('Verifying OTP for phone: ${state.phone}');
    state = state.copyWith(status: AuthStatus.loading);

    try {
      debugPrint('Calling authService.verifyOtp...');
      final response = await _authService.verifyOtp(
        phone: state.phone!,
        otp: otp,
      );
      debugPrint('OTP verification response received: accessToken=${response.accessToken.substring(0, 20)}...');

      // Store token
      await _storage.write(
        key: StorageKeys.accessToken,
        value: response.accessToken,
      );
      debugPrint('Token stored in secure storage');

      // Start session
      await ref.read(sessionServiceProvider.notifier).startSession(
        accessToken: response.accessToken,
        tokenValidity: const Duration(hours: 1), // Default token validity
      );
      debugPrint('Session started');

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: response.user,
      );
      debugPrint('State updated to authenticated');

      return true;
    } on ApiException catch (e) {
      debugPrint('ApiException during verifyOtp: ${e.message}');
      state = state.copyWith(status: AuthStatus.error, error: e.message);
      return false;
    } catch (e) {
      debugPrint('Unexpected error during verifyOtp: $e');
      state = state.copyWith(status: AuthStatus.error, error: e.toString());
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
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Auth Provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
