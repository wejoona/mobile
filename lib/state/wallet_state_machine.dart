import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/services/storage/local_cache_service.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Wallet State Machine - manages wallet balance globally
class WalletStateMachine extends Notifier<WalletState> {
  Future<void>? _refreshInFlight;
  static const _cachedBalanceWarning =
      'Live balance is temporarily unavailable. Showing last known balance.';

  @override
  WalletState build() => const WalletState();

  WalletService get _service => ref.read(walletServiceProvider);

  bool _keepCachedBalanceOnFailure() {
    final cached = ref.read(localCacheServiceProvider).getCachedWallet();
    if (cached != null) {
      state = _cachedBalanceState(
        base: state,
        status: WalletStatus.loaded,
        walletId: cached.walletId,
        walletAddress: cached.address,
        blockchain: cached.blockchain,
        usdBalance: cached.usdBalance,
        usdcBalance: cached.usdcBalance,
        pendingBalance: cached.pendingBalance,
        lastUpdated: cached.cachedAt,
      );
      debugPrint('[WalletState] Keeping cached balance (${cached.cachedAt})');
      return true;
    }

    if (state.hasBalanceData) {
      state = _degradedBalanceState(state);
      debugPrint('[WalletState] Keeping previous balance after refresh error');
      return true;
    }

    return false;
  }

  void _applyBalanceResponse(WalletBalanceResponse response) {
    var usdBalance = 0.0;
    var usdcBalance = 0.0;
    var pending = 0.0;

    for (final balance in response.balances) {
      final currency = balance.currency.toUpperCase();
      if (currency == 'USD') {
        usdBalance = balance.available;
        pending += balance.pending;
      } else if (currency == 'USDC') {
        usdcBalance = balance.available;
        pending += balance.pending;
      }
    }

    // Some backend wallet shapes expose a generic/USD row or multiple rows
    // where the spendable value is not first. Home should still render the
    // best available wallet balance instead of staying at zero.
    if (usdcBalance == 0) {
      usdcBalance = _fallbackSpendableBalance(response);
    }
    if (pending == 0 && response.balances.isNotEmpty) {
      pending = response.balances.fold<double>(
        0,
        (total, balance) => total + balance.pending,
      );
    }

    state = state.copyWith(
      status: WalletStatus.loaded,
      walletId: response.walletId,
      walletAddress: response.walletAddress,
      blockchain: response.blockchain,
      usdBalance: usdBalance,
      usdcBalance: usdcBalance,
      pendingBalance: pending,
      lastUpdated: DateTime.now(),
      isCached: false,
      isDegraded: response.degraded,
      isStale: response.isStale,
      balanceWarning: response.warning,
      balanceSourceOfTruth: response.sourceOfTruth,
      balanceReadStatus: response.readStatus,
      clearBalanceSourceOfTruth: response.sourceOfTruth == null,
      clearBalanceReadStatus: response.readStatus == null,
    );

    ref.read(localSyncServiceProvider).cacheWalletFromState(state);
    ref
        .read(appFsmProvider.notifier)
        .onWalletLoaded(
          walletId: response.walletId,
          walletAddress: response.walletAddress,
          blockchain: response.blockchain,
          usdcBalance: usdcBalance,
          pendingBalance: pending,
        );
  }

  double _fallbackSpendableBalance(WalletBalanceResponse response) {
    final matchingCurrency = response.balances
        .where(
          (balance) =>
              balance.currency.toUpperCase() == response.currency.toUpperCase(),
        )
        .map((balance) => balance.available)
        .where((amount) => amount > 0);
    if (matchingCurrency.isNotEmpty) {
      return matchingCurrency.first;
    }

    final firstPositive = response.balances
        .map((balance) => balance.available)
        .where((amount) => amount > 0);
    if (firstPositive.isNotEmpty) {
      return firstPositive.first;
    }

    return response.availableBalance;
  }

  /// Fetch wallet balance
  Future<void> fetch({bool force = false}) async {
    // Guard against redundant fetches
    if (state.status == WalletStatus.loading) {
      return;
    }

    // Pre-load cached data so UI never shows loading state on unlock
    if (state.status == WalletStatus.initial) {
      final cached = ref.read(localCacheServiceProvider).getCachedWallet();
      if (cached != null) {
        state = state.copyWith(
          status: WalletStatus.loaded,
          walletId: cached.walletId,
          walletAddress: cached.address,
          usdcBalance: cached.usdcBalance,
          usdBalance: cached.usdBalance,
          pendingBalance: cached.pendingBalance,
          blockchain: cached.blockchain,
          lastUpdated: cached.cachedAt,
          isCached: true,
          clearBalanceSourceOfTruth: true,
          clearBalanceReadStatus: true,
        );
      }
    }

    // If already loaded with valid wallet data, don't refetch automatically
    // Use refresh() for manual refresh instead, or pass force: true
    if (!force &&
        state.status == WalletStatus.loaded &&
        state.walletId.isNotEmpty &&
        !state.isCached) {
      debugPrint(
        '[WalletState] Skipping fetch - already loaded with walletId: ${state.walletId}',
      );
      // Still sync FSM in case it's out of sync (e.g., session restore)
      ref
          .read(appFsmProvider.notifier)
          .onWalletLoaded(
            walletId: state.walletId,
            walletAddress: state.walletAddress,
            blockchain: state.blockchain,
            usdcBalance: state.usdcBalance,
            pendingBalance: state.pendingBalance,
          );
      return;
    }

    state = state.copyWith(
      status: state.isCached ? WalletStatus.refreshing : WalletStatus.loading,
      isCached: state.isCached,
    );

    // Sync with FSM: notify fetch is starting
    ref.read(appFsmProvider.notifier).fetchWallet();

    try {
      final response = await _service.getBalance().timeout(
        const Duration(seconds: 12),
      );

      if (!ref.mounted) {
        return;
      }

      _applyBalanceResponse(response);
    } on ApiException catch (e) {
      // Fresh users should not be blocked by an internal wallet bootstrap step.
      // If the API says no wallet exists, create the local USDC wallet and
      // let the FSM continue to Home once creation succeeds.
      if (e.statusCode == 404) {
        state = state.copyWith(status: WalletStatus.initial);
        await createWallet();
      } else if (_keepCachedBalanceOnFailure()) {
        return;
      } else {
        state = state.copyWith(status: WalletStatus.error, error: e.message);

        // Sync with FSM: notify wallet failed
        ref.read(appFsmProvider.notifier).onWalletFailed(e.message);
      }
    } on Object catch (e) {
      // Try to return cached data on error
      final cached = ref.read(localCacheServiceProvider).getCachedWallet();
      if (cached != null) {
        state = _cachedBalanceState(
          base: state,
          status: WalletStatus.loaded,
          walletId: cached.walletId,
          walletAddress: cached.address,
          blockchain: cached.blockchain,
          usdBalance: cached.usdBalance,
          usdcBalance: cached.usdcBalance,
          pendingBalance: cached.pendingBalance,
          lastUpdated: cached.cachedAt,
        );
        debugPrint('[WalletState] Loaded from cache (${cached.cachedAt})');
        return;
      }

      state = state.copyWith(status: WalletStatus.error, error: e.toString());

      // Sync with FSM: notify wallet failed
      ref.read(appFsmProvider.notifier).onWalletFailed(e.toString());
    }
  }

  /// Refresh wallet balance (shows refreshing indicator)
  Future<void> refresh() async {
    final fallbackState = state;
    final activeRefresh = _refreshInFlight;
    if (activeRefresh != null) {
      try {
        await activeRefresh.timeout(const Duration(seconds: 14));
      } on TimeoutException {
        _recoverTimedOutRefresh(fallbackState);
        _refreshInFlight = null;
      }
      return;
    }

    final refreshFuture = _refresh();
    _refreshInFlight = refreshFuture;
    try {
      await refreshFuture.timeout(const Duration(seconds: 14));
    } on TimeoutException {
      _recoverTimedOutRefresh(fallbackState);
    } finally {
      if (identical(_refreshInFlight, refreshFuture)) {
        _refreshInFlight = null;
      }
    }
  }

  Future<void> _refresh() async {
    final previousState = state;
    state = state.copyWith(status: WalletStatus.refreshing);

    try {
      final response = await _service.getBalance().timeout(
        const Duration(seconds: 12),
      );

      if (!ref.mounted) {
        return;
      }
      _applyBalanceResponse(response);
    } on ApiException catch (e) {
      if (!ref.mounted) {
        return;
      }

      // A fresh user may not have a wallet provisioned yet. Mirror fetch():
      // create it instead of silently completing with an empty balance the
      // home screen can never render.
      if (e.statusCode == 404) {
        state = state.copyWith(status: WalletStatus.initial);
        await createWallet();
      } else {
        // Other errors: keep whatever balance we already had, just clear the
        // refreshing flag. Don't surface an error on a background refresh.
        state = previousState.hasBalanceData
            ? _degradedBalanceState(previousState)
            : state.copyWith(status: WalletStatus.error, error: e.message);
      }
    } on Object catch (e) {
      if (!ref.mounted) {
        return;
      }

      // On refresh error, keep old data but update status
      state = previousState.hasBalanceData
          ? _degradedBalanceState(previousState)
          : state.copyWith(status: WalletStatus.error, error: e.toString());
    } finally {
      if (ref.mounted && state.status == WalletStatus.refreshing) {
        state = previousState.hasBalanceData
            ? _degradedBalanceState(previousState)
            : state.copyWith(
                status: WalletStatus.error,
                error: 'Unable to refresh balance right now',
              );
      }
    }
  }

  void _recoverTimedOutRefresh(WalletState fallbackState) {
    if (!ref.mounted) {
      return;
    }

    state = fallbackState.hasBalanceData
        ? _degradedBalanceState(fallbackState)
        : state.copyWith(
            status: WalletStatus.error,
            error: 'Unable to refresh balance right now',
          );
  }

  /// Settle a screen-level refresh that has exceeded its UI budget.
  ///
  /// The underlying network refresh may still complete and apply fresh data.
  /// This keeps pull-to-refresh and the balance card from feeling stuck while
  /// making it clear that the visible balance is not freshly confirmed.
  void markRefreshDelayed() {
    if (!ref.mounted || state.status != WalletStatus.refreshing) {
      return;
    }

    state = state.hasBalanceData
        ? _degradedBalanceState(state)
        : state.copyWith(
            status: WalletStatus.error,
            error: 'Unable to refresh balance right now',
          );
  }

  WalletState _degradedBalanceState(WalletState base) => base.copyWith(
    status: WalletStatus.loaded,
    isCached: true,
    isDegraded: true,
    isStale: true,
    balanceWarning: base.balanceWarning ?? _cachedBalanceWarning,
    balanceSourceOfTruth: base.balanceSourceOfTruth ?? 'local_cache',
    balanceReadStatus: 'cached_degraded',
  );

  WalletState _cachedBalanceState({
    required WalletState base,
    required WalletStatus status,
    required String walletId,
    required String? walletAddress,
    required String blockchain,
    required double usdBalance,
    required double usdcBalance,
    required double pendingBalance,
    required DateTime lastUpdated,
  }) => base.copyWith(
    status: status,
    walletId: walletId,
    walletAddress: walletAddress,
    blockchain: blockchain,
    usdBalance: usdBalance,
    usdcBalance: usdcBalance,
    pendingBalance: pendingBalance,
    lastUpdated: lastUpdated,
    isCached: true,
    isDegraded: true,
    isStale: true,
    balanceWarning: _cachedBalanceWarning,
    balanceSourceOfTruth: 'local_cache',
    balanceReadStatus: 'cached_degraded',
  );

  /// Update balance after a transaction (optimistic update)
  void updateBalanceOptimistic({
    double? addUsd,
    double? subtractUsd,
    double? addPending,
  }) {
    state = state.copyWith(
      usdBalance: state.usdBalance + (addUsd ?? 0) - (subtractUsd ?? 0),
      pendingBalance: state.pendingBalance + (addPending ?? 0),
    );
  }

  /// Create a new wallet
  Future<void> createWallet() async {
    if (state.status == WalletStatus.loading) {
      return;
    }

    state = state.copyWith(status: WalletStatus.loading);

    try {
      final response = await _service.createWallet().timeout(
        const Duration(seconds: 18),
      );

      _applyBalanceResponse(response);

      // Sync with FSM: notify wallet created
      ref
          .read(appFsmProvider.notifier)
          .onWalletCreated(
            walletId: response.walletId,
            walletAddress: response.walletAddress,
            blockchain: response.blockchain,
          );
    } on ApiException catch (e) {
      state = state.copyWith(status: WalletStatus.error, error: e.message);

      // Sync with FSM: notify wallet failed
      ref.read(appFsmProvider.notifier).onWalletFailed(e.message);
    } on Object catch (e) {
      state = state.copyWith(status: WalletStatus.error, error: e.toString());

      // Sync with FSM: notify wallet failed
      ref.read(appFsmProvider.notifier).onWalletFailed(e.toString());
    }
  }

  /// Reset state (on logout)
  void reset() => state = const WalletState();
}

final walletStateMachineProvider =
    NotifierProvider<WalletStateMachine, WalletState>(WalletStateMachine.new);

/// Convenience providers for specific balance values
final usdcBalanceProvider = Provider<double>(
  (ref) => ref.watch(walletStateMachineProvider).usdcBalance,
);

final walletIdProvider = Provider<String>(
  (ref) => ref.watch(walletStateMachineProvider).walletId,
);

final isWalletLoadingProvider = Provider<bool>(
  (ref) => ref.watch(walletStateMachineProvider).isLoading,
);

final walletAddressProvider = Provider<String?>(
  (ref) => ref.watch(walletStateMachineProvider).walletAddress,
);

final walletBlockchainProvider = Provider<String>(
  (ref) => ref.watch(walletStateMachineProvider).blockchain,
);
