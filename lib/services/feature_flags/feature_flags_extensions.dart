import 'feature_flags_service.dart';

/// Extension on Map<String, bool> for convenient feature flag checks
/// Used in router redirects for cleaner code
extension FeatureFlagsExtension on Map<String, bool> {
  // MVP - Phase 1 (Always enabled)
  bool get canDeposit => this[FeatureFlagKeys.deposit] ?? true;
  bool get canSend => this[FeatureFlagKeys.send] ?? true;
  bool get canReceive => this[FeatureFlagKeys.receive] ?? true;
  bool get canViewTransactions => this[FeatureFlagKeys.transactions] ?? true;
  bool get canVerifyKyc => this[FeatureFlagKeys.kyc] ?? true;

  // Phase 2
  bool get canWithdraw => this[FeatureFlagKeys.withdraw] ?? false;
  bool get canOffRamp => this[FeatureFlagKeys.offRamp] ?? false;

  // Phase 3
  bool get canBuyAirtime => this[FeatureFlagKeys.airtime] ?? false;
  bool get canPayBills => this[FeatureFlagKeys.bills] ?? false;

  // Phase 4
  bool get canSetSavingsGoals => this[FeatureFlagKeys.savings] ?? false;
  bool get canUseSavingsPots => this[FeatureFlagKeys.savingsPots] ?? false;
  bool get canUseVirtualCards => this[FeatureFlagKeys.virtualCards] ?? false;
  bool get canSplitBills => this[FeatureFlagKeys.splitBills] ?? false;
  bool get canScheduleTransfers => this[FeatureFlagKeys.recurringTransfers] ?? false;
  bool get canUseBudget => this[FeatureFlagKeys.budget] ?? false;

  // Phase 5
  bool get canUseAgentNetwork => this[FeatureFlagKeys.agentNetwork] ?? false;
  bool get canUseUssd => this[FeatureFlagKeys.ussd] ?? false;

  // Other features
  bool get canReferFriends => this[FeatureFlagKeys.referrals] ?? false;
  bool get canViewAnalytics => this[FeatureFlagKeys.analytics] ?? false;
  bool get canUseCurrencyConverter => this[FeatureFlagKeys.currencyConverter] ?? false;
  bool get canRequestMoney => this[FeatureFlagKeys.requestMoney] ?? false;
  bool get canUseSavedRecipients => this[FeatureFlagKeys.savedRecipients] ?? false;

  // Backend controlled features
  bool get canUseTwoFactorAuth => this[FeatureFlagKeys.twoFactorAuth] ?? false;
  bool get canUseExternalTransfers => this[FeatureFlagKeys.externalTransfers] ?? false;
  bool get canUseBillPayments => this[FeatureFlagKeys.billPayments] ?? false;
  bool get canUseBiometricAuth => this[FeatureFlagKeys.biometricAuth] ?? false;
  bool get canUseMobileMoneyWithdrawals => this[FeatureFlagKeys.mobileMoneyWithdrawals] ?? false;
}
