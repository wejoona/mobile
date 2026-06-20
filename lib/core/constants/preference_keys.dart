/// SharedPreferences keys for non-sensitive app state.
abstract final class PreferenceKeys {
  /// Product introduction/tutorial completion.
  ///
  /// Keep the legacy string so existing installs that completed the intro do
  /// not see it again after the signup flow moves to its own key.
  static const productIntroCompleted = 'onboarding_completed';

  /// Account creation and initial setup completion.
  static const signupSetupCompleted = 'signup_setup_completed';

  static const firstDepositCompleted = 'onboarding_first_deposit';
  static const firstTransferCompleted = 'onboarding_first_transfer';
  static const kycPromptSeen = 'onboarding_kyc_prompt';
  static const tooltipsSeen = 'onboarding_tooltips';
  static const dismissedOnboardingPrompts = 'onboarding_dismissed_prompts';
  static const firstLoginAt = 'onboarding_first_login';
}
