import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/index.dart';
import '../services/wallet/wallet_service.dart';
import 'app_state.dart';

/// Wallet State Machine - manages wallet balance globally
class WalletStateMachine extends Notifier<WalletState> {
  @override
  WalletState build() {
    // Auto-fetch on initialization if authenticated
    _autoFetch();
    return const WalletState();
  }

  WalletService get _service => ref.read(walletServiceProvider);

  void _autoFetch() {
    // Schedule fetch after build
    Future.microtask(() => fetch());
  }

  /// Fetch wallet balance
  Future<void> fetch() async {
    if (state.status == WalletStatus.loading) return;

    state = state.copyWith(status: WalletStatus.loading);

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
    } on ApiException catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        error: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: WalletStatus.error,
        error: e.toString(),
      );
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
final usdBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletStateMachineProvider).usdBalance;
});

final usdcBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletStateMachineProvider).usdcBalance;
});

final totalBalanceProvider = Provider<double>((ref) {
  return ref.watch(walletStateMachineProvider).totalBalance;
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
