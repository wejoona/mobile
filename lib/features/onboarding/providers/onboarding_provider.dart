import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

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

  // === Stub methods for view compatibility ===
  Future<void> submitPhoneNumber([String? phone]) async {
    if (phone != null) state = state.copyWith(phoneNumber: phone);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/register', data: {
        'phone': state.phoneNumber,
        if (state.countryCode != null) 'countryCode': state.countryCode,
      });
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
  Future<void> verifyOtp([String? otp]) async {
    if (otp != null) state = state.copyWith(otp: otp);
    state = state.copyWith(isLoading: true, error: null);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/auth/verify-otp', data: {
        'phone': state.phoneNumber,
        'otp': state.otp,
      });
      state = state.copyWith(isLoading: false);
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
    state = state.copyWith(otpResendCountdown: 60);
  }
  void startKyc() {}

  /// Skip KYC — notify backend so it records the user's choice,
  /// then mark onboarding complete locally.
  Future<void> skipKyc() async {
    state = state.copyWith(isLoading: true);
    try {
      final dio = ref.read(dioProvider);
      await dio.post('/user/kyc/skip');
    } catch (_) {
      // Non-blocking — still complete onboarding even if backend call fails
    }
    await completeOnboarding();
    state = state.copyWith(isLoading: false);
  }

}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);

/// Whether to show onboarding.
final shouldShowOnboardingProvider = Provider<bool>((ref) {
  final state = ref.watch(onboardingProvider);
  return !state.isLoading && !state.isComplete;
});
