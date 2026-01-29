/// Onboarding state model
class OnboardingState {
  final OnboardingStep currentStep;
  final String? phoneNumber;
  final String? countryCode;
  final String? otp;
  final String? pin;
  final String? firstName;
  final String? lastName;
  final String? email;
  final bool isLoading;
  final String? error;
  final int otpResendCountdown;
  final String? sessionToken;

  const OnboardingState({
    this.currentStep = OnboardingStep.welcome,
    this.phoneNumber,
    this.countryCode = '+225',
    this.otp,
    this.pin,
    this.firstName,
    this.lastName,
    this.email,
    this.isLoading = false,
    this.error,
    this.otpResendCountdown = 0,
    this.sessionToken,
  });

  OnboardingState copyWith({
    OnboardingStep? currentStep,
    String? phoneNumber,
    String? countryCode,
    String? otp,
    String? pin,
    String? firstName,
    String? lastName,
    String? email,
    bool? isLoading,
    String? error,
    int? otpResendCountdown,
    String? sessionToken,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      otp: otp ?? this.otp,
      pin: pin ?? this.pin,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      otpResendCountdown: otpResendCountdown ?? this.otpResendCountdown,
      sessionToken: sessionToken ?? this.sessionToken,
    );
  }

  bool get canProceed {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return true;
      case OnboardingStep.phoneInput:
        return phoneNumber != null && phoneNumber!.isNotEmpty;
      case OnboardingStep.otpVerification:
        return otp != null && otp!.length == 6;
      case OnboardingStep.pinSetup:
        return pin != null && pin!.length == 6;
      case OnboardingStep.profileSetup:
        return firstName != null &&
               firstName!.isNotEmpty &&
               lastName != null &&
               lastName!.isNotEmpty;
      case OnboardingStep.kycPrompt:
        return true;
      case OnboardingStep.success:
        return true;
    }
  }
}

/// Onboarding flow steps
enum OnboardingStep {
  welcome,
  phoneInput,
  otpVerification,
  pinSetup,
  profileSetup,
  kycPrompt,
  success,
}
