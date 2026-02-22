import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/index.dart';

/// Onboarding state.
class OnboardingState {
  final int currentPage;
  final bool isComplete;
  final bool isLoading;
  final String? error;
  final String? phoneNumber;
  final String? countryCode;
  final String? otp;
  final String? pin;
  final String? firstName;
  final String? lastName;
  final String? email;
  final int otpResendCountdown;
  final String? sessionToken;
  final String? refreshToken;
  final String? verificationId;
  final int? otpExpiresIn;

  const OnboardingState({
    this.currentPage = 0,
    this.isComplete = false,
    this.isLoading = true,
    this.error,
    this.phoneNumber,
    this.countryCode,
    this.otp,
    this.pin,
    this.firstName,
    this.lastName,
    this.email,
    this.otpResendCountdown = 0,
    this.sessionToken,
    this.refreshToken,
    this.verificationId,
    this.otpExpiresIn,
  });

  OnboardingState copyWith({
    int? currentPage,
    bool? isComplete,
    bool? isLoading,
    String? error,
    String? phoneNumber,
    String? countryCode,
    String? otp,
    String? pin,
    String? firstName,
    String? lastName,
    String? email,
    int? otpResendCountdown,
    String? sessionToken,
    String? refreshToken,
    String? verificationId,
    int? otpExpiresIn,
    bool clearError = false,
  }) => OnboardingState(
    currentPage: currentPage ?? this.currentPage,
    isComplete: isComplete ?? this.isComplete,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    phoneNumber: phoneNumber ?? this.phoneNumber,
    countryCode: countryCode ?? this.countryCode,
    otp: otp ?? this.otp,
    pin: pin ?? this.pin,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    otpResendCountdown: otpResendCountdown ?? this.otpResendCountdown,
    sessionToken: sessionToken ?? this.sessionToken,
    refreshToken: refreshToken ?? this.refreshToken,
    verificationId: verificationId ?? this.verificationId,
    otpExpiresIn: otpExpiresIn ?? this.otpExpiresIn,
  );
}

/// Onboarding notifier.
class OnboardingNotifier extends Notifier<OnboardingState> {
  static const _key = 'korido_onboarding_complete';

  @override
  OnboardingState build() {
    _checkStatus();
    return const OnboardingState();
  }

  Future<void> _checkStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final complete = prefs.getBool(_key) ?? false;
    state = state.copyWith(isComplete: complete, isLoading: false);
  }

  void nextPage() {
    state = state.copyWith(currentPage: state.currentPage + 1);
  }

  void previousPage() {
    if (state.currentPage > 0) {
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  void goToPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
    state = state.copyWith(isComplete: true);
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    state = const OnboardingState(isLoading: false);
  }

  Timer? _resendTimer;

  // === Auth methods ===
  Future<void> submitPhoneNumber([String? phone]) async {
    if (phone != null) state = state.copyWith(phoneNumber: phone);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.register(
        phone: state.phoneNumber!,
        countryCode: state.countryCode ?? 'CI',
      );
      state = state.copyWith(
        isLoading: false,
        verificationId: response.verificationId,
        otpExpiresIn: response.expiresIn,
      );
      _startResendCountdown();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifyOtp([String? otp]) async {
    if (otp != null) state = state.copyWith(otp: otp);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.verifyOtp(
        phone: state.phoneNumber!,
        otp: state.otp!,
        verificationId: state.verificationId,
      );
      state = state.copyWith(
        isLoading: false,
        sessionToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  void updateOtp(String otp) => state = state.copyWith(otp: otp);
  void updatePhoneNumber(String phone, [String? countryCode]) => state = state.copyWith(phoneNumber: phone, countryCode: countryCode);
  Future<void> submitPin(String pin) async => state = state.copyWith(pin: pin);
  Future<void> submitProfile([Map<String, dynamic>? data, String? firstName, String? lastName, String? email]) async {
    final fn = firstName ?? data?['firstName'] as String?;
    final ln = lastName ?? data?['lastName'] as String?;
    final em = email ?? data?['email'] as String?;
    state = state.copyWith(firstName: fn, lastName: ln, email: em);
  }
  Future<void> updateProfile({Map<String, dynamic>? data, String? firstName, String? lastName, String? email}) async {
    await submitProfile(data, firstName, lastName, email);
  }
  Future<void> resendOtp() async {
    if (state.otpResendCountdown > 0) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final authService = ref.read(authServiceProvider);
      final response = await authService.register(
        phone: state.phoneNumber!,
        countryCode: state.countryCode ?? 'CI',
      );
      state = state.copyWith(
        isLoading: false,
        verificationId: response.verificationId,
        otpExpiresIn: response.expiresIn,
      );
      _startResendCountdown();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

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
  void startKyc() {}
  void skipKyc() => state = state.copyWith(isComplete: true);

}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);

/// Whether to show onboarding.
final shouldShowOnboardingProvider = Provider<bool>((ref) {
  final state = ref.watch(onboardingProvider);
  return !state.isLoading && !state.isComplete;
});
