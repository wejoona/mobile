import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../services/api/api_client.dart';
import '../../../services/pin/pin_service.dart';
import '../models/onboarding_state.dart';

/// Onboarding state provider
final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(
  OnboardingNotifier.new,
);

/// Onboarding state machine
class OnboardingNotifier extends Notifier<OnboardingState> {
  Timer? _resendTimer;

  @override
  OnboardingState build() {
    ref.onDispose(() {
      _resendTimer?.cancel();
    });
    return const OnboardingState();
  }

  Dio get _dio => ref.read(dioProvider);
  FlutterSecureStorage get _storage => ref.read(secureStorageProvider);

  /// Navigate to next step
  void nextStep() {
    final currentIndex = OnboardingStep.values.indexOf(state.currentStep);
    if (currentIndex < OnboardingStep.values.length - 1) {
      state = state.copyWith(
        currentStep: OnboardingStep.values[currentIndex + 1],
        error: null,
      );
    }
  }

  /// Navigate to specific step
  void goToStep(OnboardingStep step) {
    state = state.copyWith(
      currentStep: step,
      error: null,
    );
  }

  /// Update phone number
  void updatePhoneNumber(String phoneNumber, String countryCode) {
    state = state.copyWith(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      error: null,
    );
  }

  /// Submit phone number for registration
  /// Calls POST /auth/register { phone, countryCode }
  Future<void> submitPhoneNumber() async {
    if (state.phoneNumber == null || state.phoneNumber!.isEmpty) {
      state = state.copyWith(error: 'Phone number is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Build E.164 phone: countryCode + phoneNumber
      final phone = '${state.countryCode}${state.phoneNumber}';

      await _dio.post('/auth/register', data: {
        'phone': phone,
        'countryCode': 'CI', // Default; derive from state.countryCode if needed
      });

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.otpVerification,
      );

      _startResendCountdown();
    } on DioException catch (e) {
      final message = ApiException.fromDioError(e).message;
      state = state.copyWith(
        isLoading: false,
        error: message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
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
  /// Calls POST /auth/verify-otp { phone, otp }
  /// Returns { accessToken, refreshToken, user, expiresIn, kycStatus }
  Future<void> verifyOtp() async {
    if (state.otp == null || state.otp!.length != 6) {
      state = state.copyWith(error: 'Please enter a valid 6-digit code');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final phone = '${state.countryCode}${state.phoneNumber}';

      final response = await _dio.post('/auth/verify-otp', data: {
        'phone': phone,
        'otp': state.otp,
      });

      final data = response.data as Map<String, dynamic>;

      // Store tokens
      await _storage.write(
        key: StorageKeys.accessToken,
        value: data['accessToken'] as String,
      );
      await _storage.write(
        key: StorageKeys.refreshToken,
        value: data['refreshToken'] as String,
      );

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.pinSetup,
        sessionToken: data['accessToken'] as String,
      );

      _resendTimer?.cancel();
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid code. Please try again.',
      );
      // Clear OTP after error
      Future.delayed(const Duration(milliseconds: 500), () {
        state = state.copyWith(otp: '');
      });
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid code. Please try again.',
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        state = state.copyWith(otp: '');
      });
    }
  }

  /// Resend OTP
  /// Calls POST /auth/login { phone } to trigger a new OTP
  Future<void> resendOtp() async {
    if (state.otpResendCountdown > 0) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final phone = '${state.countryCode}${state.phoneNumber}';

      await _dio.post('/auth/login', data: {
        'phone': phone,
      });

      state = state.copyWith(isLoading: false);
      _startResendCountdown();
    } on DioException catch (e) {
      final message = ApiException.fromDioError(e).message;
      state = state.copyWith(
        isLoading: false,
        error: message,
      );
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

  /// Update PIN
  void updatePin(String pin) {
    state = state.copyWith(
      pin: pin,
      error: null,
    );
  }

  /// Submit PIN
  /// Uses PinService which calls POST /wallet/pin/set
  Future<void> submitPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null, pin: pin);

    try {
      final pinService = ref.read(pinServiceProvider);
      final success = await pinService.setPin(pin);

      if (success) {
        state = state.copyWith(
          isLoading: false,
          currentStep: OnboardingStep.profileSetup,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to set PIN. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to set PIN. Please try again.',
      );
    }
  }

  /// Update profile
  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) {
    state = state.copyWith(
      firstName: firstName ?? state.firstName,
      lastName: lastName ?? state.lastName,
      email: email ?? state.email,
      error: null,
    );
  }

  /// Submit profile
  /// Calls PUT /user/profile { firstName, lastName, email }
  Future<void> submitProfile() async {
    if (state.firstName == null || state.firstName!.isEmpty) {
      state = state.copyWith(error: 'First name is required');
      return;
    }
    if (state.lastName == null || state.lastName!.isEmpty) {
      state = state.copyWith(error: 'Last name is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      await _dio.put('/user/profile', data: {
        'firstName': state.firstName,
        'lastName': state.lastName,
        if (state.email != null && state.email!.isNotEmpty)
          'email': state.email,
      });

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.kycPrompt,
      );
    } on DioException catch (e) {
      final message = ApiException.fromDioError(e).message;
      state = state.copyWith(
        isLoading: false,
        error: message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to save profile. Please try again.',
      );
    }
  }

  /// Skip KYC and complete onboarding
  void skipKyc() {
    state = state.copyWith(
      currentStep: OnboardingStep.success,
    );
  }

  /// Start KYC flow
  void startKyc() {
    // Navigate to KYC flow
    // This will be handled by the router
  }

  /// Complete onboarding
  void completeOnboarding() {
    // Reset state
    state = const OnboardingState();
  }

  /// Reset onboarding state
  void reset() {
    _resendTimer?.cancel();
    state = const OnboardingState();
  }
}
