import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:usdc_wallet/features/auth/models/login_state.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/features/auth/providers/session_provider.dart';
import 'package:usdc_wallet/features/settings/providers/devices_provider.dart';
import 'package:usdc_wallet/services/device/device_registration_service.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

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
    unawaited(_loadRememberedPhone());

    return const LoginState();
  }

  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);
  AuthService get _authService => ref.read(authServiceProvider);

  /// Load remembered phone number
  Future<void> _loadRememberedPhone() async {
    try {
      final rememberedPhone = await _storage.read(
        key: StorageKeys.rememberedPhone,
      );
      if (rememberedPhone != null) {
        final phoneValue = PhoneNumberValue.tryFromStorageValue(
          rememberedPhone,
        );
        if (phoneValue != null) {
          if ((state.phoneNumber ?? '').isNotEmpty) {
            return;
          }
          state = state
              .withPhoneValue(phoneValue)
              .copyWith(rememberDevice: true);
        }
      }
    } catch (e) {
      // Ignore errors loading remembered phone
    }
  }

  /// Update phone number
  void updatePhoneNumber(String phoneNumber, String dialCode) {
    final phoneValue = PhoneNumberValue.tryFromAny(
      phoneNumber: phoneNumber,
      countryCode: dialCode,
    );
    final localPhoneNumber =
        phoneValue?.localNumber ??
        localPhoneDigits(dialCode: dialCode, phoneNumber: phoneNumber);
    state =
        (phoneValue == null
                ? state.copyWith(
                    phoneNumber: localPhoneNumber,
                    dialCode: dialCode,
                  )
                : state.withPhoneValue(phoneValue))
            .copyWith(error: null);
  }

  /// Toggle remember device
  void toggleRememberDevice() {
    state = state.copyWith(rememberDevice: !state.rememberDevice);
  }

  /// Submit phone number for login
  Future<void> submitPhoneNumber() async {
    final phoneValue = _currentPhoneValue();
    if (phoneValue == null) {
      state = state.copyWith(error: 'Phone number is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Call login API
      final response = await _authService.login(
        phone: phoneValue.apiPhone,
        countryCode: phoneValue.apiCountryCode,
      );

      // Save remembered phone if enabled
      if (state.rememberDevice) {
        await _storage.write(
          key: StorageKeys.rememberedPhone,
          value: phoneValue.storageValue,
        );
      } else {
        await _storage.delete(key: StorageKeys.rememberedPhone);
      }

      state = state.copyWith(isLoading: false, currentStep: LoginStep.otp);

      _startResendCountdown(response.resendAvailableIn);
    } catch (e) {
      final retryAfterSeconds = _otpRetryAfterSeconds(e);
      if (retryAfterSeconds != null) {
        _startResendCountdown(retryAfterSeconds);
      }
      state = state.copyWith(
        isLoading: false,
        error: _otpRequestErrorMessage(
          e,
          isResend: false,
          retryAfterSeconds: retryAfterSeconds,
        ),
      );
    }
  }

  /// Update OTP
  void updateOtp(String otp) {
    state = state.copyWith(otp: otp, error: null);
  }

  /// Verify OTP
  Future<void> verifyOtp() async {
    if (state.otp == null || state.otp!.length != 6) {
      state = state.copyWith(error: 'Please enter a valid 6-digit code');
      return;
    }
    final phoneValue = _currentPhoneValue();
    if (phoneValue == null) {
      state = state.copyWith(error: 'Phone number is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.verifyOtp(
        phone: phoneValue.apiPhone,
        countryCode: phoneValue.apiCountryCode,
        otp: state.otp!,
      );

      state = state.copyWith(
        isLoading: false,
        currentStep: LoginStep.pin,
        sessionToken: response.accessToken,
        refreshToken: response.refreshToken,
        sessionExpiresIn: response.expiresIn,
        user: response.user,
        kycStatus: response.kycStatus,
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
    final phoneValue = _currentPhoneValue();
    if (phoneValue == null) {
      state = state.copyWith(error: 'Phone number is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _authService.login(
        phone: phoneValue.apiPhone,
        countryCode: phoneValue.apiCountryCode,
      );
      state = state.copyWith(isLoading: false);
      _startResendCountdown(response.resendAvailableIn);
    } catch (e) {
      final retryAfterSeconds = _otpRetryAfterSeconds(e);
      if (retryAfterSeconds != null) {
        _startResendCountdown(retryAfterSeconds);
      }
      state = state.copyWith(
        isLoading: false,
        error: _otpRequestErrorMessage(
          e,
          isResend: true,
          retryAfterSeconds: retryAfterSeconds,
        ),
      );
    }
  }

  int? _otpRetryAfterSeconds(Object error) {
    if (error is ApiException) {
      return error.resendAvailableIn ?? error.retryAfterSeconds;
    }
    return null;
  }

  String _otpRequestErrorMessage(
    Object error, {
    required bool isResend,
    int? retryAfterSeconds,
  }) {
    if (error is ApiException) {
      final message = error.message.trim();
      final normalized = message.toLowerCase();
      final code = error.code?.toUpperCase();
      final isRateLimited =
          error.statusCode == 429 ||
          code == 'TOO_MANY_REQUESTS' ||
          code == 'E9001' ||
          code == 'RATE_LIMITED' ||
          normalized.contains('too many') ||
          normalized.contains('rate limit');
      if (isRateLimited) {
        if (retryAfterSeconds != null) {
          return _verificationCooldownMessage(retryAfterSeconds);
        }
        return 'Verification is temporarily paused. Please wait a moment before requesting another code.';
      }

      final statusCode = error.statusCode;
      if (statusCode != null && statusCode >= 500 && message.isNotEmpty) {
        return message;
      }
    }

    if (isResend) {
      return 'Failed to resend code. Please try again.';
    }

    // SECURITY: Generic error to prevent account enumeration attacks.
    return 'Unable to log in. Please check your details and try again.';
  }

  /// Start OTP resend countdown
  void _startResendCountdown([int seconds = 60]) {
    final waitSeconds = _normalizedCooldownSeconds(seconds);
    state = state.copyWith(otpResendCountdown: waitSeconds);
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.otpResendCountdown > 0) {
        state = state.copyWith(
          otpResendCountdown: state.otpResendCountdown - 1,
        );
      } else {
        timer.cancel();
      }
    });
  }

  int _normalizedCooldownSeconds(int seconds) {
    if (seconds <= 0) return 60;
    if (seconds > 3600) return 3600;
    return seconds;
  }

  String _verificationCooldownMessage(int seconds) {
    final waitSeconds = _normalizedCooldownSeconds(seconds);
    final minutes = (waitSeconds / 60).ceil();
    final waitCopy = waitSeconds < 60
        ? '$waitSeconds seconds'
        : '$minutes minute${minutes == 1 ? '' : 's'}';
    return 'Use the verification code already sent. You can request another in $waitCopy.';
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Verify PIN with backend — returns a PIN token for subsequent requests
      final pinService = ref.read(pinServiceProvider);
      final pinResult = await pinService.verifyPinWithBackend(pin);

      if (!pinResult.success) {
        throw Exception(pinResult.message ?? 'PIN verification failed');
      }

      // Store auth token and complete login via session provider (single source of truth)
      if (state.sessionToken != null) {
        await ref
            .read(sessionProvider.notifier)
            .setTokens(
              accessToken: state.sessionToken!,
              refreshToken: state.refreshToken ?? state.sessionToken!,
            );
      }

      // Register device + FCM token with backend
      try {
        final deviceService = ref.read(deviceRegistrationServiceProvider);
        await deviceService.registerCurrentDevice();
        ref
          ..invalidate(devicesProvider)
          ..invalidate(localDeviceIdProvider);
      } catch (_) {
        // Non-blocking — don't fail login if device registration fails
      }

      // Unlock session so router doesn't redirect to lock screen
      try {
        ref.read(authProvider.notifier).unlock();
      } catch (_) {}
      try {
        ref.read(sessionServiceProvider.notifier).unlockSession();
      } catch (_) {}

      state = state.copyWith(
        isLoading: false,
        currentStep: LoginStep.success,
        pinAttempts: 0,
      );

      return true;
    } catch (e) {
      // Use backend lockout state from PinService if available
      final pinService = ref.read(pinServiceProvider);
      final lockCheck = await pinService.verifyPinLocally('');
      // ^ Quick check to get lockout state (will fail but returns lock info)

      final newAttempts = state.pinAttempts + 1;

      if (lockCheck.isLocked) {
        // Backend/local lockout is active
        state = state.copyWith(
          isLoading: false,
          isLocked: true,
          pinAttempts: newAttempts,
          error:
              lockCheck.message ?? 'Too many failed attempts. Account locked.',
        );
        _startLockoutTimer(lockCheck.lockRemainingSeconds ?? 900);
      } else if (newAttempts >= 3) {
        state = state.copyWith(
          isLoading: false,
          isLocked: true,
          pinAttempts: newAttempts,
          error: 'Too many failed attempts. Account locked for 15 minutes.',
        );
        _startLockoutTimer(900);
      } else {
        final remaining = lockCheck.remainingAttempts ?? (3 - newAttempts);
        state = state.copyWith(
          isLoading: false,
          pinAttempts: newAttempts,
          error: 'Incorrect PIN, $remaining attempts remaining',
        );
      }

      return false;
    }
  }

  /// Start lockout timer with duration from backend
  void _startLockoutTimer(int seconds) {
    _lockoutTimer?.cancel();
    _lockoutTimer = Timer(Duration(seconds: seconds), () {
      state = state.copyWith(isLocked: false, pinAttempts: 0, error: null);
    });
  }

  /// Navigate to specific step
  void goToStep(LoginStep step) {
    state = state.copyWith(currentStep: step, error: null);
  }

  /// Reset login state
  void reset() {
    _resendTimer?.cancel();
    _lockoutTimer?.cancel();
    final phoneValue = state.phoneValue;
    state = LoginState(
      dialCode: phoneValue?.dialCode ?? state.dialCode,
      phoneNumber: state.rememberDevice ? phoneValue?.localNumber : null,
      rememberDevice: state.rememberDevice,
    );
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  PhoneNumberValue? _currentPhoneValue() {
    return state.phoneValue;
  }
}
