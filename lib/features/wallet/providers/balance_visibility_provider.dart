import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/settings/providers/app_preferences_provider.dart';

/// Whether the wallet balance is visible or hidden (eye toggle).
final balanceVisibilityProvider = Provider<bool>((ref) {
  return ref.watch(appPreferencesProvider).showBalance;
});

/// Toggle balance visibility.
final toggleBalanceVisibilityProvider = Provider<Future<void> Function()>((ref) {
  return () => ref.read(appPreferencesProvider.notifier).toggleBalanceVisibility();
});
