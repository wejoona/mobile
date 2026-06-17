import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart' as auth;
import 'package:usdc_wallet/services/pin/pin_service.dart';
import 'package:usdc_wallet/services/legal/legal_documents_service.dart';
import 'package:usdc_wallet/services/user/user_service.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';
import 'package:usdc_wallet/utils/phone_number_normalizer.dart';

/// Onboarding state.
class OnboardingState {
  final int currentPage;
  final bool isComplete;
  final bool isLoading;
  final String? error;
  final String? phoneNumber;
  final String? countryCode;
  final String? dialCode;
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
    this.dialCode,
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
    String? dialCode,
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
    dialCode: dialCode ?? this.dialCode,
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
  static const _key = 'onboarding_completed';

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

  Future<void> submitPhoneNumber({
    String? phone,
    bool acceptedTerms = false,
  }) async {
    final phoneNumber = _localPhoneNumber(phone ?? state.phoneNumber);
    final countryCode = state.countryCode ?? 'CI';

    if (phoneNumber == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'Phone number is required',
      );
      return;
    }

    state = state.copyWith(
      phoneNumber: phoneNumber,
      countryCode: countryCode,
      isLoading: true,
      clearError: true,
    );

    try {
      final legalDocuments = await ref
          .read(legalDocumentsServiceProvider)
          .getAllDocuments();
      await ref
          .read(auth.authProvider.notifier)
          .register(
            phoneNumber,
            countryCode,
            acceptedTerms: acceptedTerms,
            termsVersion: legalDocuments.$1.version,
            privacyVersion: legalDocuments.$2.version,
          );
      final authState = ref.read(auth.authProvider);
      if (authState.status == auth.AuthStatus.otpSent) {
        state = state.copyWith(isLoading: false, clearError: true);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: authState.error ?? 'Unable to send verification code',
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFrom(e));
    }
  }

  Future<void> verifyOtp([String? otp]) async {
    final code = otp ?? state.otp;
    if (code == null || code.length != 6) {
      state = state.copyWith(
        isLoading: false,
        error: 'Enter the 6-digit verification code',
      );
      return;
    }

    state = state.copyWith(otp: code, isLoading: true, clearError: true);

    try {
      final verified = await ref
          .read(auth.authProvider.notifier)
          .verifyOtp(code);
      final authState = ref.read(auth.authProvider);
      state = state.copyWith(
        isLoading: false,
        error: verified ? null : authState.error ?? 'Unable to verify code',
        clearError: verified,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFrom(e));
    }
  }

  void updateOtp(String otp) => state = state.copyWith(otp: otp);

  void updatePhoneNumber(
    String phone, [
    String? countryCode,
    String? dialCode,
  ]) {
    state = state.copyWith(
      phoneNumber: _localPhoneNumber(phone, dialCode: dialCode),
      countryCode: countryCode,
      dialCode: dialCode,
      clearError: true,
    );
  }

  Future<void> submitPin(String pin) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final success = await ref
          .read(pinServiceProvider)
          .setPin(pin, requireBackendSync: true);
      state = state.copyWith(
        pin: success ? pin : state.pin,
        isLoading: false,
        error: success ? null : 'Unable to set PIN',
        clearError: success,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFrom(e));
    }
  }

  Future<void> submitProfile({
    Map<String, dynamic>? data,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    final fn = firstName ?? data?['firstName'] as String? ?? state.firstName;
    final ln = lastName ?? data?['lastName'] as String? ?? state.lastName;
    final em = email ?? data?['email'] as String? ?? state.email;

    if (fn == null || fn.trim().isEmpty || ln == null || ln.trim().isEmpty) {
      state = state.copyWith(
        isLoading: false,
        error: 'First name and last name are required',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final trimmedEmail = em?.trim();
      final profile = await ref
          .read(userServiceProvider)
          .updateProfile(
            firstName: fn.trim(),
            lastName: ln.trim(),
            email: trimmedEmail == null || trimmedEmail.isEmpty
                ? null
                : trimmedEmail,
          );

      ref
          .read(userStateMachineProvider.notifier)
          .updateProfile(
            firstName: profile.firstName,
            lastName: profile.lastName,
            email: profile.email,
            avatarUrl: profile.avatarUrl,
            avatarThumb: profile.avatarThumb,
          );

      state = state.copyWith(
        firstName: profile.firstName,
        lastName: profile.lastName,
        email: profile.email,
        isLoading: false,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _messageFrom(e));
    }
  }

  void updateProfile({
    Map<String, dynamic>? data,
    String? firstName,
    String? lastName,
    String? email,
  }) {
    state = state.copyWith(
      firstName: firstName ?? data?['firstName'] as String?,
      lastName: lastName ?? data?['lastName'] as String?,
      email: email ?? data?['email'] as String?,
      clearError: true,
    );
  }

  Future<void> resendOtp() async {
    await submitPhoneNumber(acceptedTerms: true);
    if (state.error == null) {
      state = state.copyWith(otpResendCountdown: 60);
    }
  }

  void startKyc() {
    state = state.copyWith(clearError: true);
  }

  /// Skip KYC for now and mark onboarding complete locally.
  Future<void> skipKyc() async {
    state = state.copyWith(isLoading: true, clearError: true);
    await completeOnboarding();
    state = state.copyWith(isLoading: false);
  }

  String? _localPhoneNumber(String? phone, {String? dialCode}) {
    final raw = phone?.trim();
    if (raw == null || raw.isEmpty) return null;
    final selectedDialCode = dialCode ?? state.dialCode;
    if (selectedDialCode != null && selectedDialCode.isNotEmpty) {
      return localPhoneDigits(dialCode: selectedDialCode, phoneNumber: raw);
    }
    return digitsOnly(raw);
  }

  String _messageFrom(Object error) {
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );

/// Whether to show onboarding.
final shouldShowOnboardingProvider = Provider<bool>((ref) {
  final state = ref.watch(onboardingProvider);
  return !state.isLoading && !state.isComplete;
});
