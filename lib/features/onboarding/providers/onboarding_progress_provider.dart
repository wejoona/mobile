import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onboarding progress tracking
class OnboardingProgress {
  final bool hasSeenTutorial;
  final bool hasCompletedFirstDeposit;
  final bool hasCompletedFirstTransfer;
  final bool hasSeenKycPrompt;
  final bool hasSeenTooltips;
  final Set<String> dismissedPrompts;
  final DateTime? firstLoginAt;

  const OnboardingProgress({
    this.hasSeenTutorial = false,
    this.hasCompletedFirstDeposit = false,
    this.hasCompletedFirstTransfer = false,
    this.hasSeenKycPrompt = false,
    this.hasSeenTooltips = false,
    this.dismissedPrompts = const {},
    this.firstLoginAt,
  });

  OnboardingProgress copyWith({
    bool? hasSeenTutorial,
    bool? hasCompletedFirstDeposit,
    bool? hasCompletedFirstTransfer,
    bool? hasSeenKycPrompt,
    bool? hasSeenTooltips,
    Set<String>? dismissedPrompts,
    DateTime? firstLoginAt,
  }) {
    return OnboardingProgress(
      hasSeenTutorial: hasSeenTutorial ?? this.hasSeenTutorial,
      hasCompletedFirstDeposit: hasCompletedFirstDeposit ?? this.hasCompletedFirstDeposit,
      hasCompletedFirstTransfer: hasCompletedFirstTransfer ?? this.hasCompletedFirstTransfer,
      hasSeenKycPrompt: hasSeenKycPrompt ?? this.hasSeenKycPrompt,
      hasSeenTooltips: hasSeenTooltips ?? this.hasSeenTooltips,
      dismissedPrompts: dismissedPrompts ?? this.dismissedPrompts,
      firstLoginAt: firstLoginAt ?? this.firstLoginAt,
    );
  }

  bool get isNewUser => firstLoginAt != null &&
    DateTime.now().difference(firstLoginAt!).inDays < 7;

  bool get shouldShowDepositPrompt => !hasCompletedFirstDeposit && !dismissedPrompts.contains('deposit_prompt');

  bool get shouldShowKycPrompt => !hasSeenKycPrompt && hasCompletedFirstDeposit;

  bool get shouldShowTooltips => !hasSeenTooltips && hasCompletedFirstDeposit;
}

/// Onboarding progress notifier
class OnboardingProgressNotifier extends Notifier<OnboardingProgress> {
  static const String _keyTutorial = 'onboarding_tutorial';
  static const String _keyFirstDeposit = 'onboarding_first_deposit';
  static const String _keyFirstTransfer = 'onboarding_first_transfer';
  static const String _keyKycPrompt = 'onboarding_kyc_prompt';
  static const String _keyTooltips = 'onboarding_tooltips';
  static const String _keyDismissed = 'onboarding_dismissed_prompts';
  static const String _keyFirstLogin = 'onboarding_first_login';

  @override
  OnboardingProgress build() {
    _loadProgress();
    return const OnboardingProgress();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();

    final dismissedList = prefs.getStringList(_keyDismissed) ?? [];
    final firstLoginStr = prefs.getString(_keyFirstLogin);

    state = OnboardingProgress(
      hasSeenTutorial: prefs.getBool(_keyTutorial) ?? false,
      hasCompletedFirstDeposit: prefs.getBool(_keyFirstDeposit) ?? false,
      hasCompletedFirstTransfer: prefs.getBool(_keyFirstTransfer) ?? false,
      hasSeenKycPrompt: prefs.getBool(_keyKycPrompt) ?? false,
      hasSeenTooltips: prefs.getBool(_keyTooltips) ?? false,
      dismissedPrompts: Set.from(dismissedList),
      firstLoginAt: firstLoginStr != null ? DateTime.parse(firstLoginStr) : null,
    );
  }

  Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTutorial, true);
    state = state.copyWith(hasSeenTutorial: true);
  }

  Future<void> markFirstDepositCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstDeposit, true);
    state = state.copyWith(hasCompletedFirstDeposit: true);
  }

  Future<void> markFirstTransferCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstTransfer, true);
    state = state.copyWith(hasCompletedFirstTransfer: true);
  }

  Future<void> markKycPromptSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKycPrompt, true);
    state = state.copyWith(hasSeenKycPrompt: true);
  }

  Future<void> markTooltipsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTooltips, true);
    state = state.copyWith(hasSeenTooltips: true);
  }

  Future<void> dismissPrompt(String promptId) async {
    final prefs = await SharedPreferences.getInstance();
    final newDismissed = {...state.dismissedPrompts, promptId};
    await prefs.setStringList(_keyDismissed, newDismissed.toList());
    state = state.copyWith(dismissedPrompts: newDismissed);
  }

  Future<void> setFirstLogin() async {
    if (state.firstLoginAt != null) return; // Already set

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setString(_keyFirstLogin, now.toIso8601String());
    state = state.copyWith(firstLoginAt: now);
  }

  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTutorial);
    await prefs.remove(_keyFirstDeposit);
    await prefs.remove(_keyFirstTransfer);
    await prefs.remove(_keyKycPrompt);
    await prefs.remove(_keyTooltips);
    await prefs.remove(_keyDismissed);
    await prefs.remove(_keyFirstLogin);
    state = const OnboardingProgress();
  }
}

final onboardingProgressProvider = NotifierProvider<OnboardingProgressNotifier, OnboardingProgress>(
  OnboardingProgressNotifier.new,
);
