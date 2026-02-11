import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
import 'feature_flags_service.dart';

// Re-export for convenience
export 'feature_flags_service.dart' show FeatureFlagKeys;

/// Shared Preferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Feature Flags Service Provider
final featureFlagsServiceProvider = Provider<FeatureFlagsService>((ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return FeatureFlagsService(dio, prefs);
});

/// Feature Flags State Provider
///
/// Holds the current state of all feature flags.
/// Auto-refreshes every 15 minutes and on user login.
final featureFlagsProvider = NotifierProvider<FeatureFlagsNotifier, Map<String, bool>>(
  FeatureFlagsNotifier.new,
);

class FeatureFlagsNotifier extends Notifier<Map<String, bool>> {
  FeatureFlagsService? _service;

  @override
  Map<String, bool> build() {
    _init();
    return {};
  }

  Future<void> _init() async {
    _service = ref.read(featureFlagsServiceProvider);
    await _service!.init();
    state = _service!.getAll();
  }

  /// Load flags from API
  Future<void> loadFlags() async {
    _service ??= ref.read(featureFlagsServiceProvider);
    final flags = await _service!.fetchFlags();
    state = flags;
  }

  /// Check if a flag is enabled
  bool isEnabled(String key) {
    return state[key] ?? false;
  }

  /// Refresh flags from server
  Future<void> refresh() async {
    _service ??= ref.read(featureFlagsServiceProvider);
    await _service!.refresh();
    state = _service!.getAll();
  }

  /// Clear cache (for testing)
  Future<void> clearCache() async {
    _service ??= ref.read(featureFlagsServiceProvider);
    await _service!.clearCache();
    state = {};
  }
}

/// Convenience providers for individual flags

final twoFactorAuthEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.twoFactorAuth] ?? false;
});

final externalTransfersEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.externalTransfers] ?? false;
});

final billPaymentsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.billPayments] ?? false;
});

final savingsPotsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.savingsPots] ?? false;
});

final biometricAuthEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.biometricAuth] ?? false;
});

final mobileMoneyWithdrawalsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.mobileMoneyWithdrawals] ?? false;
});

final merchantQrEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.merchantQr] ?? false;
});

final paymentLinksEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.paymentLinks] ?? false;
});

final referralProgramEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.referralProgram] ?? false;
});

final recurringTransfersEnabledProvider = Provider<bool>((ref) {
  return ref.watch(featureFlagsProvider)[FeatureFlagKeys.recurringTransfers] ?? false;
});
