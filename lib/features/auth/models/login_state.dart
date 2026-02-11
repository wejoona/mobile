/// Login state model
class LoginState {
  final LoginStep currentStep;
  final String? phoneNumber;
  final String? countryCode;
  final String? otp;
  final bool isLoading;
  final String? error;
  final int otpResendCountdown;
  final String? sessionToken;
  final String? refreshToken;
  final bool rememberDevice;
  final int pinAttempts;
  final bool isLocked;

  const LoginState({
    this.currentStep = LoginStep.phone,
    this.phoneNumber,
    this.countryCode = '+225',
    this.otp,
    this.isLoading = false,
    this.error,
    this.otpResendCountdown = 0,
    this.sessionToken, this.refreshToken,
    this.rememberDevice = true,
    this.pinAttempts = 0,
    this.isLocked = false,
  });

  LoginState copyWith({
    LoginStep? currentStep,
    String? phoneNumber,
    String? countryCode,
    String? otp,
    bool? isLoading,
    String? error,
    int? otpResendCountdown,
    String? sessionToken, String? refreshToken,
    bool? rememberDevice,
    int? pinAttempts,
    bool? isLocked,
  }) {
    return LoginState(
      currentStep: currentStep ?? this.currentStep,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      otp: otp ?? this.otp,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      otpResendCountdown: otpResendCountdown ?? this.otpResendCountdown,
      sessionToken: sessionToken ?? this.sessionToken, refreshToken: refreshToken ?? this.refreshToken,
      rememberDevice: rememberDevice ?? this.rememberDevice,
      pinAttempts: pinAttempts ?? this.pinAttempts,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  int get remainingAttempts => 3 - pinAttempts;
}

/// Login flow steps
enum LoginStep {
  phone,
  otp,
  pin,
  biometric,
  success,
}

/// Login request model
class LoginRequest {
  final String phoneNumber;
  final String countryCode;

  const LoginRequest({
    required this.phoneNumber,
    this.countryCode = '+225',
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'countryCode': countryCode,
      };
}
