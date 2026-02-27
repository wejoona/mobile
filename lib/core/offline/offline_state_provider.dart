import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:usdc_wallet/services/storage/local_cache_service.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';

/// Offline state exposed to the UI
class OfflineState {
  final bool isOnline;
  final int pendingOpsCount;
  final DateTime? walletLastSync;
  final DateTime? transactionsLastSync;
  final DateTime? userProfileLastSync;
  final bool hasStaleData;

  const OfflineState({
    this.isOnline = true,
    this.pendingOpsCount = 0,
    this.walletLastSync,
    this.transactionsLastSync,
    this.userProfileLastSync,
    this.hasStaleData = false,
  });
}

/// Provider that exposes offline/sync state to the UI
final offlineStateProvider = Provider<OfflineState>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  final cache = ref.read(localCacheServiceProvider);

  if (!cache.isInitialized) {
    return OfflineState(isOnline: connectivity.isOnline);
  }

  final walletSync = cache.getLastSyncAt('wallet');
  final txSync = cache.getLastSyncAt('transactions');
  final profileSync = cache.getLastSyncAt('userProfile');

  final hasStale = cache.isStale('wallet', StaleThresholds.wallet) ||
      cache.isStale('transactions', StaleThresholds.transactions);

  return OfflineState(
    isOnline: connectivity.isOnline,
    pendingOpsCount: cache.pendingOpsCount,
    walletLastSync: walletSync,
    transactionsLastSync: txSync,
    userProfileLastSync: profileSync,
    hasStaleData: hasStale,
  );
});

/// Convenience providers
final hasPendingOpsProvider = Provider<bool>((ref) {
  return ref.watch(offlineStateProvider).pendingOpsCount > 0;
});

final isDataStaleProvider = Provider<bool>((ref) {
  return ref.watch(offlineStateProvider).hasStaleData;
});
