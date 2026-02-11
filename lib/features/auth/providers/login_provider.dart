import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/features/auth/models/login_state.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/services/device/device_registration_service.dart';

/// Login state provider
final loginProvider = NotifierProvider<LoginNotifier, LoginState>(
  LoginNotifier.new,
);

/// Login state machine
class LoginNotifier extends Notifier<LoginState> {
  Timer? _resendTimer;
  Timer? _lockoutTimer;

  @override
  LoginState build() {
    ref.onDispose(() {
      _resendTimer?.cancel();
      _lockoutTimer?.cancel();
    });

    // Load remembered phone number
    _loadRememberedPhone();

    return const LoginState();
  }

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);
  AuthService get _authService => ref.read(authServiceProvider);

  /// Load remembered phone number
  Future<void> _loadRememberedPhone() async {
    try {
      final rememberedPhone = await _storage.read(key: StorageKeys.rememberedPhone);
      if (rememberedPhone != null) {
        final parts = rememberedPhone.split('|');
        if (parts.length == 2) {
          state = state.copyWith(
            countryCode: parts[0],
            phoneNumber: parts[1],
            rememberDevice: true,
          );
        }
      }
    } catch (e) {
      // Ignore errors loading remembered phone
    }
  }

  /// Update phone number
  void updatePhoneNumber(String phoneNumber, String countryCode) {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      error: null,
    );
  }

  /// Toggle remember device
  void toggleRememberDevice() {
    state = state.copyWith(rememberDevice: !state.rememberDevice);
  }

  /// Submit phone number for login
  Future<void> submitPhoneNumber() async {
    if (state.phoneNumber == null || state.phoneNumber!.isEmpty) {
      state = state.copyWith(error: 'Phone number is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call login API
      await _authService.login(phone: state.phoneNumber!);

      // Save remembered phone if enabled
      if (state.rememberDevice) {
        await _storage.write(
          key: StorageKeys.rememberedPhone,
          value: '${state.countryCode}|${state.phoneNumber}',
        );
      } else {
        await _storage.delete(key: StorageKeys.rememberedPhone);
      }

      state = state.copyWith(
        isLoading: false,
        currentStep: LoginStep.otp,
      );

      _startResendCountdown();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Account not found. Please check your phone number or create a new account.',
      );
    }
  }

  /// Update OTP
  void updateOtp(String otp) {
    state = state.copyWith(
      otp: otp,
      error: null,
    );
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (state.otp == null || state.otp!.length != 6) {
      state = state.copyWith(error: 'Please enter a valid 6-digit code');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.verifyOtp(
        phone: state.phoneNumber!,
        otp: state.otp!,
      );

      state = state.copyWith(
        isLoading: false,
        currentStep: LoginStep.pin,
        sessionToken: response.accessToken,
      );

      _resendTimer?.cancel();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid code, try again',
      );
      // Clear OTP after error
      Future.delayed(const Duration(milliseconds: 500), () {
        state = state.copyWith(otp: '');
      });
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    if (state.otpResendCountdown > 0) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _authService.login(phone: state.phoneNumber!);
      state = state.copyWith(isLoading: false);
      _startResendCountdown();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to resend code. Please try again.',
      );
    }
  }

  /// Start OTP resend countdown
  void _startResendCountdown() {
    state = state.copyWith(otpResendCountdown: 60);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.otpResendCountdown > 0) {
        state = state.copyWith(otpResendCountdown: state.otpResendCountdown - 1);
      } else {
        timer.cancel();
      }
    });
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call PIN verification API
      // For now, mock: any 6-digit PIN works (or specifically "123456")
      await Future.delayed(const Duration(seconds: 1));

      // Store auth token and complete login
      if (state.sessionToken != null) {
        await _storage.write(
          key: StorageKeys.accessToken,
          value: state.sessionToken!,
        );
      }

      // Register device + FCM token with backend
      try {
        final deviceService = ref.read(deviceRegistrationServiceProvider);
        await deviceService.registerCurrentDevice();
      } catch (_) {
        // Non-blocking — don't fail login if device registration fails
      }

      state = state.copyWith(
        isLoading: false,
        currentStep: LoginStep.success,
        pinAttempts: 0,
      );

      return true;
    } catch (e) {
      final newAttempts = state.pinAttempts + 1;

      if (newAttempts >= 3) {
        // Lock account after 3 failed attempts
        state = state.copyWith(
          isLoading: false,
          isLocked: true,
          pinAttempts: newAttempts,
          error: 'Too many failed attempts. Account locked for 15 minutes.',
        );
        _startLockoutTimer();
      } else {
        state = state.copyWith(
          isLoading: false,
          pinAttempts: newAttempts,
          error: 'Incorrect PIN, ${3 - newAttempts} attempts remaining',
        );
      }

      return false;
    }
  }

  /// Start lockout timer
  void _startLockoutTimer() {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer(const Duration(minutes: 15), () {
      state = state.copyWith(
        isLocked: false,
        pinAttempts: 0,
        error: null,
      );
    });
  }

  /// Verify biometric
  Future<bool> verifyBiometric() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call biometric service
      final biometricService = ref.read(biometricServiceProvider);
      final success = await biometricService.authenticate(
        reason: 'Verify your identity to login',
      );

      if (success) {
        // Store auth token and complete login
        if (state.sessionToken != null) {
          await _storage.write(
            key: StorageKeys.accessToken,
            value: state.sessionToken!,
          );
        }

        state = state.copyWith(
          isLoading: false,
          currentStep: LoginStep.success,
        );

        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Biometric authentication failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Navigate to specific step
  void goToStep(LoginStep step) {
    state = state.copyWith(
      currentStep: step,
      error: null,
    );
  }

  /// Reset login state
  void reset() {
    _resendTimer?.cancel();
    _lockoutTimer?.cancel();
    state = LoginState(
      countryCode: state.countryCode,
      phoneNumber: state.rememberDevice ? state.phoneNumber : null,
      rememberDevice: state.rememberDevice,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
