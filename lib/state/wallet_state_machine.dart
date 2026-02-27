import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/index.dart';
import 'package:usdc_wallet/services/wallet/wallet_service.dart';
import 'package:usdc_wallet/services/storage/local_cache_service.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Wallet State Machine - manages wallet balance globally
class WalletStateMachine extends Notifier<WalletState> {
  @override
  WalletState build() {
    // Don't auto-fetch on build - wallet fetch is triggered by FSM after auth
    // This prevents 401 errors when the provider is created before authentication
    return const WalletState();
  }

  WalletService get _service => ref.read(walletServiceProvider);

  /// Fetch wallet balance
  Future<void> fetch({bool force = false}) async {
    // Guard against redundant fetches
    if (state.status == WalletStatus.loading) return;

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
        );
      }
    }

    // If already loaded with valid wallet data, don't refetch automatically
    // Use refresh() for manual refresh instead, or pass force: true
    if (!force && state.status == WalletStatus.loaded && state.walletId.isNotEmpty) {
      debugPrint('[WalletState] Skipping fetch - already loaded with walletId: ${state.walletId}');
      // Still sync FSM in case it's out of sync (e.g., session restore)
      ref.read(appFsmProvider.notifier).onWalletLoaded(
        walletId: state.walletId,
        walletAddress: state.walletAddress,
        blockchain: state.blockchain,
        usdcBalance: state.usdcBalance,
        pendingBalance: state.pendingBalance,
      );
      return;
    }

    state = state.copyWith(status: WalletStatus.loading);

    // Sync with FSM: notify fetch is starting
    ref.read(appFsmProvider.notifier).fetchWallet();

    try {
      final response = await _service.getBalance();

      double usdBalance = 0;
      double usdcBalance = 0;
      double pending = 0;

      for (final balance in response.balances) {
        if (balance.currency == 'USD') {
          usdBalance = balance.available;
          pending += balance.pending;
        } else if (balance.currency == 'USDC') {
          usdcBalance = balance.available;
          pending += balance.pending;
        }
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
        error: null,
      );

      // Cache locally for offline access
      ref.read(localSyncServiceProvider).cacheWalletFromState(state);

      // Sync with FSM: notify wallet loaded
      ref.read(appFsmProvider.notifier).onWalletLoaded(
        walletId: response.walletId,
        walletAddress: response.walletAddress,
        blockchain: response.blockchain,
        usdcBalance: usdcBalance,
        pendingBalance: pending,
      );
    } on ApiException catch (e) {
      // If 404 "Wallet not found", set loaded state with empty wallet
      // This triggers the "Create Wallet" card in home view
      if (e.statusCode == 404 && e.message.contains('Wallet not found')) {
        state = state.copyWith(
          status: WalletStatus.loaded,
          walletId: '',
          walletAddress: null,
          usdBalance: 0,
          usdcBalance: 0,
          pendingBalance: 0,
          error: null,
        );

        // Sync with FSM: notify wallet not found
        ref.read(appFsmProvider.notifier).onWalletNotFound();
      } else {
        state = state.copyWith(
          status: WalletStatus.error,
          error: e.message,
        );

        // Sync with FSM: notify wallet failed
        ref.read(appFsmProvider.notifier).onWalletFailed(e.message);
      }
    } catch (e) {
      // Try to return cached data on error
      final cached = ref.read(localCacheServiceProvider).getCachedWallet();
      if (cached != null) {
        state = state.copyWith(
          status: WalletStatus.loaded,
          walletId: cached.walletId,
          walletAddress: cached.address,
          blockchain: cached.blockchain,
          usdBalance: cached.usdBalance,
          usdcBalance: cached.usdcBalance,
          pendingBalance: cached.pendingBalance,
          lastUpdated: cached.cachedAt,
          isCached: true,
          error: null,
        );
        debugPrint('[WalletState] Loaded from cache (${cached.cachedAt})');
        return;
      }

      state = state.copyWith(
        status: WalletStatus.error,
        error: e.toString(),
      );

      // Sync with FSM: notify wallet failed
      ref.read(appFsmProvider.notifier).onWalletFailed(e.toString());
    }
  }

  /// Refresh wallet balance (shows refreshing indicator)
  Future<void> refresh() async {
    if (state.isLoading) return;

    state = state.copyWith(status: WalletStatus.refreshing);

    try {
      final response = await _service.getBalance();

      double usdBalance = 0;
      double usdcBalance = 0;
      double pending = 0;

      for (final balance in response.balances) {
        if (balance.currency == 'USD') {
          usdBalance = balance.available;
          pending += balance.pending;
        } else if (balance.currency == 'USDC') {
          usdcBalance = balance.available;
          pending += balance.pending;
        }
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
        error: null,
      );
    } catch (e) {
      // On refresh error, keep old data but update status
      state = state.copyWith(
        status: WalletStatus.loaded,
        error: null, // Don't show error on refresh fail
      );
    }
  }

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
    if (state.status == WalletStatus.loading) return;

    state = state.copyWith(status: WalletStatus.loading);

    try {
      final response = await _service.createWallet();

      // Debug: log the response data
      debugPrint('[WalletState] createWallet response - walletId: "${response.walletId}", walletAddress: "${response.walletAddress}", balances: ${response.balances.length}');
      for (final b in response.balances) {
        debugPrint('[WalletState] Balance: ${b.currency} available=${b.available} pending=${b.pending}');
      }

      double usdBalance = 0;
      double usdcBalance = 0;
      double pending = 0;

      for (final balance in response.balances) {
        if (balance.currency == 'USD') {
          usdBalance = balance.available;
          pending += balance.pending;
        } else if (balance.currency == 'USDC') {
          usdcBalance = balance.available;
          pending += balance.pending;
        }
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
        error: null,
      );

      // Debug: log the final state
      debugPrint('[WalletState] State updated - walletId: "${state.walletId}", status: ${state.status}, usdcBalance: ${state.usdcBalance}');

      // Sync with FSM: notify wallet created
      ref.read(appFsmProvider.notifier).onWalletCreated(
        walletId: response.walletId,
        walletAddress: response.walletAddress,
        blockchain: response.blockchain,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        error: e.message,
      );

      // Sync with FSM: notify wallet failed
      ref.read(appFsmProvider.notifier).onWalletFailed(e.message);
    } catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        error: e.toString(),
      );

      // Sync with FSM: notify wallet failed
      ref.read(appFsmProvider.notifier).onWalletFailed(e.toString());
    }
  }

  /// Reset state (on logout)
  void reset() {
    state = const WalletState();
  }
}

final walletStateMachineProvider =
    NotifierProvider<WalletStateMachine, WalletState>(
  WalletStateMachine.new,
);

/// Convenience providers for specific balance values
final usdcBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletStateMachineProvider).usdcBalance;
});

final walletIdProvider = Provider<String>((ref) {
  return ref.watch(walletStateMachineProvider).walletId;
});

final isWalletLoadingProvider = Provider<bool>((ref) {
  return ref.watch(walletStateMachineProvider).isLoading;
});

final walletAddressProvider = Provider<String?>((ref) {
  return ref.watch(walletStateMachineProvider).walletAddress;
});

final walletBlockchainProvider = Provider<String>((ref) {
  return ref.watch(walletStateMachineProvider).blockchain;
});
