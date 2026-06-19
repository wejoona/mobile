import 'package:usdc_wallet/domain/entities/index.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Login state model
class LoginState {
  final LoginStep currentStep;
  final String? phoneNumber;
  final String? dialCode;
  final String? otp;
  final bool isLoading;
  final String? error;
  final int otpResendCountdown;
  final String? sessionToken;
  final String? refreshToken;
  final int? sessionExpiresIn;
  final User? user;
  final String? kycStatus;
  final bool rememberDevice;
  final int pinAttempts;
  final bool isLocked;

  const LoginState({
    this.currentStep = LoginStep.phone,
    this.phoneNumber,
    this.dialCode = '+225',
    this.otp,
    this.isLoading = false,
    this.error,
    this.otpResendCountdown = 0,
    this.sessionToken,
    this.refreshToken,
    this.sessionExpiresIn,
    this.user,
    this.kycStatus,
    this.rememberDevice = true,
    this.pinAttempts = 0,
    this.isLocked = false,
  });

  LoginState copyWith({
    LoginStep? currentStep,
    String? phoneNumber,
    String? dialCode,
    String? otp,
    bool? isLoading,
    String? error,
    int? otpResendCountdown,
    String? sessionToken,
    String? refreshToken,
    int? sessionExpiresIn,
    User? user,
    String? kycStatus,
    bool? rememberDevice,
    int? pinAttempts,
    bool? isLocked,
  }) {
    return LoginState(
      currentStep: currentStep ?? this.currentStep,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dialCode: dialCode ?? this.dialCode,
      otp: otp ?? this.otp,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      otpResendCountdown: otpResendCountdown ?? this.otpResendCountdown,
      sessionToken: sessionToken ?? this.sessionToken,
      refreshToken: refreshToken ?? this.refreshToken,
      sessionExpiresIn: sessionExpiresIn ?? this.sessionExpiresIn,
      user: user ?? this.user,
      kycStatus: kycStatus ?? this.kycStatus,
      rememberDevice: rememberDevice ?? this.rememberDevice,
      pinAttempts: pinAttempts ?? this.pinAttempts,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  int get remainingAttempts => 3 - pinAttempts;

  PhoneNumberValue? get phoneValue => PhoneNumberValue.tryFromAny(
    phoneNumber: phoneNumber,
    countryCode: dialCode,
  );

  String? get localPhoneNumber => phoneValue?.localNumber ?? phoneNumber;
  String get canonicalDialCode => phoneValue?.dialCode ?? dialCode ?? '+225';

  LoginState withPhoneValue(PhoneNumberValue phoneValue) {
    return copyWith(
      phoneNumber: phoneValue.localNumber,
      dialCode: phoneValue.dialCode,
    );
  }
}

/// Login flow steps
enum LoginStep { phone, otp, pin, biometric, success }
