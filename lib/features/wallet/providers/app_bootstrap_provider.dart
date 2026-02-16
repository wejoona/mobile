import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/features/profile/providers/profile_provider.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/services/risk/session_risk_provider.dart';

/// Data needed at app launch, fetched in parallel.
///
/// Essential data:
/// - User profile
/// - Wallet balance
/// - Recent transactions (last 5)
/// - Feature flags
///
/// NOT needed at launch (lazy-loaded):
/// - Full transaction history
/// - Cards list
/// - Referrals
/// - Settings details
///
/// TODO: Replace parallel fetches with a single `/api/v1/init` backend
/// endpoint that returns all essential data in one call. This reduces
/// cold-start latency from N round-trips to 1.
class AppBootstrapData {
  final double availableBalance;
  final bool profileLoaded;
  final bool featureFlagsLoaded;
  final bool transactionsLoaded;

  const AppBootstrapData({
    required this.availableBalance,
    required this.profileLoaded,
    required this.featureFlagsLoaded,
    required this.transactionsLoaded,
  });

  bool get isComplete =>
      profileLoaded && featureFlagsLoaded && transactionsLoaded;
}

class AppBootstrapNotifier extends AsyncNotifier<AppBootstrapData> {
  @override
  Future<AppBootstrapData> build() => _bootstrap();

  Future<AppBootstrapData> _bootstrap() async {
    if (kDebugMode) debugPrint('[Bootstrap] Starting app bootstrap...');

    // Fire all essential requests in parallel
    final results = await Future.wait([
      _loadBalance(),
      _loadProfile(),
      _loadFeatureFlags(),
      _loadRecentTransactions(),
    ], eagerError: false);

    final data = AppBootstrapData(
      availableBalance: results[0] as double,
      profileLoaded: results[1] as bool,
      featureFlagsLoaded: results[2] as bool,
      transactionsLoaded: results[3] as bool,
    );

    if (kDebugMode) debugPrint('[Bootstrap] Complete: ${data.isComplete}');

    // Fire-and-forget: assess session risk silently (don't block startup)
    assessSessionRiskFromRef(ref).ignore();

    return data;
  }

  Future<double> _loadBalance() async {
    try {
      final balance = await ref.read(walletBalanceProvider.future);
      return balance.available;
    } catch (e) {
      if (kDebugMode) debugPrint('[Bootstrap] Balance failed: $e');
      return 0;
    }
  }

  Future<bool> _loadProfile() async {
    try {
      await ref.read(profileProvider.notifier).loadProfile();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[Bootstrap] Profile failed: $e');
      return false;
    }
  }

  Future<bool> _loadFeatureFlags() async {
    try {
      await ref.read(featureFlagsProvider.notifier).refresh();
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[Bootstrap] Feature flags failed: $e');
      return false;
    }
  }

  Future<bool> _loadRecentTransactions() async {
    try {
      // Reading the provider triggers the fetch via the state machine
      ref.read(recentTransactionsProvider);
      return true;
    } catch (e) {
      if (kDebugMode) debugPrint('[Bootstrap] Transactions failed: $e');
      return false;
    }
  }

  /// Retry the entire bootstrap sequence.
  Future<void> retry() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _bootstrap());
  }

  /// Invalidate and re-fetch a specific data source.
  Future<void> refreshBalance() async {
    ref.invalidate(walletBalanceProvider);
  }
}

final appBootstrapProvider =
    AsyncNotifierProvider<AppBootstrapNotifier, AppBootstrapData>(
  AppBootstrapNotifier.new,
);
