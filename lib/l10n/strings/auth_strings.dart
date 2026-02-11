/// User-facing strings for authentication flows.
library;

abstract final class AuthStrings {
  // Login
  static const loginTitle = 'Welcome Back';
  static const loginSubtitle = 'Enter your phone number to continue';
  static const phoneLabel = 'Phone Number';
  static const phoneHint = 'Enter your phone number';
  static const loginButton = 'Log In';
  static const signUpPrompt = 'Don\'t have an account?';
  static const signUpButton = 'Sign Up';

  // OTP
  static const otpTitle = 'Verify Your Number';
  static const otpSubtitle = 'Enter the 6-digit code sent to';
  static const otpHint = 'Enter code';
  static const resendCode = 'Resend Code';
  static const resendIn = 'Resend in';
  static const codeExpired = 'Code expired. Please request a new one.';
  static const invalidOtp = 'Invalid code. Please try again.';

  // PIN
  static const enterPin = 'Enter PIN';
  static const createPin = 'Create PIN';
  static const confirmPin = 'Confirm PIN';
  static const changePin = 'Change PIN';
  static const currentPin = 'Enter Current PIN';
  static const newPin = 'Enter New PIN';
  static const confirmNewPin = 'Confirm New PIN';
  static const pinChanged = 'PIN changed successfully';
  static const forgotPin = 'Forgot PIN?';
  static const biometricPrompt = 'Authenticate to continue';
  static const biometricFailed = 'Authentication failed. Please try again.';

  // Account
  static const accountLocked = 'Account Locked';
  static const accountLockedMessage = 'Too many failed attempts. Please try again later.';
  static const accountSuspended = 'Account Suspended';
  static const accountSuspendedMessage = 'Your account has been suspended. Please contact support.';
  static const logOut = 'Log Out';
  static const logOutConfirm = 'Are you sure you want to log out?';
}
