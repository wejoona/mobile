/// Standardized animation and timeout durations across the app.
library;

abstract final class AppDurations {
  // Animations
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Duration animPageTransition = Duration(milliseconds: 350);
  static const Duration animShimmer = Duration(milliseconds: 1500);

  // Debounce
  static const Duration debounceSearch = Duration(milliseconds: 400);
  static const Duration debounceInput = Duration(milliseconds: 300);
  static const Duration debounceButton = Duration(milliseconds: 500);

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 60);
  static const Duration otpExpiry = Duration(minutes: 5);
  static const Duration otpResendCooldown = Duration(seconds: 60);
  static const Duration sessionTimeout = Duration(minutes: 30);
  static const Duration autoLockTimeout = Duration(minutes: 5);

  // Polling
  static const Duration depositStatusPoll = Duration(seconds: 10);
  static const Duration balanceRefresh = Duration(minutes: 1);
  static const Duration notificationPoll = Duration(minutes: 5);

  // UI
  static const Duration snackBarDuration = Duration(seconds: 3);
  static const Duration toastDuration = Duration(seconds: 2);
  static const Duration splashMinDuration = Duration(seconds: 2);
}
