import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/onboarding_state.dart';
import '../models/registration_request.dart';

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
  Future<void> submitPhoneNumber() async {
    if (state.phoneNumber == null || state.phoneNumber!.isEmpty) {
      state = state.copyWith(error: 'Phone number is required');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call API to register phone number
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock: any phone number works
      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.otpVerification,
      );

      _startResendCountdown();
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
  Future<void> verifyOtp() async {
    if (state.otp == null || state.otp!.length != 6) {
      state = state.copyWith(error: 'Please enter a valid 6-digit code');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Call API to verify OTP
      // For now, simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mock: any 6 digits work, or specifically "123456"
      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.pinSetup,
        sessionToken: 'mock-session-token',
      );

      _resendTimer?.cancel();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Invalid code. Please try again.',
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
      // TODO: Call API to resend OTP
      await Future.delayed(const Duration(seconds: 1));

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

  /// Update PIN
  void updatePin(String pin) {
    state = state.copyWith(
      pin: pin,
      error: null,
    );
  }

  /// Submit PIN
  Future<void> submitPin(String pin) async {
    state = state.copyWith(isLoading: true, error: null, pin: pin);

    try {
      // TODO: Call API to set PIN
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.profileSetup,
      );
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
      // TODO: Call API to update profile
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(
        isLoading: false,
        currentStep: OnboardingStep.kycPrompt,
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
