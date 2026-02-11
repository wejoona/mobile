import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding state.
class OnboardingState {
  final int currentPage;
  final bool isComplete;
  final bool isLoading;

  const OnboardingState({this.currentPage = 0, this.isComplete = false, this.isLoading = true});

  OnboardingState copyWith({int? currentPage, bool? isComplete, bool? isLoading}) => OnboardingState(
    currentPage: currentPage ?? this.currentPage,
    isComplete: isComplete ?? this.isComplete,
    isLoading: isLoading ?? this.isLoading,
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
}

final onboardingProvider = NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);

/// Whether to show onboarding.
final shouldShowOnboardingProvider = Provider<bool>((ref) {
  final state = ref.watch(onboardingProvider);
  return !state.isLoading && !state.isComplete;
});
