import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/domain/entities/transaction.dart';
import 'package:usdc_wallet/features/beneficiaries/models/beneficiary.dart';
import 'package:usdc_wallet/services/offline/offline_cache_service.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:uuid/uuid.dart';

/// Offline Mode Manager
/// Coordinates caching, offline operations, and queue management
class OfflineModeManager {
  final OfflineCacheService _cache;
  final PendingTransferQueue _queue;
  final Ref _ref;

  OfflineModeManager(this._cache, this._queue, this._ref);

  // ============================================================
  // Balance Operations
  // ============================================================

  /// Get balance (cached if offline)
  Future<CachedData<double>?> getBalance() async {
    final isOnline = _ref.read(isOnlineProvider);

    if (isOnline) {
      // Fetch fresh data
      // TODO: Integrate with actual wallet service
      // final sdk = _ref.read(sdkProvider);
      // final balance = await sdk.wallet.getBalance();
      // await _cache.cacheBalance(balance);
      // return CachedData(data: balance, isCached: false);

      // For now, return cached
      final cached = _cache.getCachedBalance();
      if (cached != null) {
        return CachedData(
          data: cached,
          isCached: false,
          lastSync: _cache.getLastSync(),
        );
      }
    }

    // Return cached data
    final cached = _cache.getCachedBalance();
    if (cached != null) {
      return CachedData(
        data: cached,
        isCached: true,
        lastSync: _cache.getLastSync(),
      );
    }

    return null;
  }

  /// Update cached balance
  Future<void> updateBalance(double balance) async {
    await _cache.cacheBalance(balance);
    _ref.read(connectivityProvider.notifier).updateLastSync();
  }

  // ============================================================
  // Transaction Operations
  // ============================================================

  /// Get transactions (cached if offline)
  Future<CachedData<List<Transaction>>?> getTransactions() async {
    final isOnline = _ref.read(isOnlineProvider);

    if (isOnline) {
      // Fetch fresh data
      // TODO: Integrate with actual transactions service
      // final sdk = _ref.read(sdkProvider);
      // final transactions = await sdk.transactions.getList();
      // await _cache.cacheTransactions(transactions);
      // return CachedData(data: transactions, isCached: false);

      // For now, return cached
      final cached = _cache.getCachedTransactions();
      if (cached != null) {
        return CachedData(
          data: cached,
          isCached: false,
          lastSync: _cache.getLastSync(),
        );
      }
    }

    // Return cached data
    final cached = _cache.getCachedTransactions();
    if (cached != null) {
      return CachedData(
        data: cached,
        isCached: true,
        lastSync: _cache.getLastSync(),
      );
    }

    return null;
  }

  /// Update cached transactions
  Future<void> updateTransactions(List<Transaction> transactions) async {
    await _cache.cacheTransactions(transactions);
    _ref.read(connectivityProvider.notifier).updateLastSync();
  }

  // ============================================================
  // Beneficiary Operations
  // ============================================================

  /// Get beneficiaries (cached if offline)
  Future<CachedData<List<Beneficiary>>?> getBeneficiaries() async {
    final isOnline = _ref.read(isOnlineProvider);

    if (isOnline) {
      // Fetch fresh data
      // TODO: Integrate with actual beneficiaries service
      // final sdk = _ref.read(sdkProvider);
      // final beneficiaries = await sdk.beneficiaries.getList();
      // await _cache.cacheBeneficiaries(beneficiaries);
      // return CachedData(data: beneficiaries, isCached: false);

      // For now, return cached
      final cached = _cache.getCachedBeneficiaries();
      if (cached != null) {
        return CachedData(
          data: cached,
          isCached: false,
          lastSync: _cache.getLastSync(),
        );
      }
    }

    // Return cached data
    final cached = _cache.getCachedBeneficiaries();
    if (cached != null) {
      return CachedData(
        data: cached,
        isCached: true,
        lastSync: _cache.getLastSync(),
      );
    }

    return null;
  }

  /// Update cached beneficiaries
  Future<void> updateBeneficiaries(List<Beneficiary> beneficiaries) async {
    await _cache.cacheBeneficiaries(beneficiaries);
    _ref.read(connectivityProvider.notifier).updateLastSync();
  }

  // ============================================================
  // Transfer Queue Operations
  // ============================================================

  /// Queue a transfer (for offline mode)
  Future<String> queueTransfer({
    required String recipientPhone,
    String? recipientName,
    required double amount,
    String? description,
  }) async {
    final transfer = PendingTransfer(
      id: const Uuid().v4(),
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      amount: amount,
      description: description,
      timestamp: DateTime.now(),
      status: TransferStatus.pending,
    );

    await _queue.enqueue(transfer);

    // Update pending count in connectivity provider
    await _ref.read(connectivityProvider.notifier).refreshPendingCount();

    return transfer.id;
  }

  /// Get all pending transfers
  List<PendingTransfer> getPendingTransfers() {
    return _queue.getQueue();
  }

  /// Retry a failed transfer
  Future<void> retryTransfer(String transferId) async {
    await _queue.updateTransferStatus(transferId, TransferStatus.pending);
    await _ref.read(connectivityProvider.notifier).refreshPendingCount();

    // Trigger queue processing if online
    final isOnline = _ref.read(isOnlineProvider);
    if (isOnline) {
      await _ref.read(connectivityProvider.notifier).processQueueManually();
    }
  }

  /// Cancel a pending transfer
  Future<void> cancelTransfer(String transferId) async {
    await _queue.removeTransfer(transferId);
    await _ref.read(connectivityProvider.notifier).refreshPendingCount();
  }

  /// Clear completed transfers
  Future<void> clearCompleted() async {
    await _queue.clearCompleted();
    await _ref.read(connectivityProvider.notifier).refreshPendingCount();
  }

  // ============================================================
  // Offline-Capable Features Check
  // ============================================================

  /// Check if a feature is available offline
  bool isFeatureAvailableOffline(OfflineFeature feature) {
    switch (feature) {
      case OfflineFeature.viewBalance:
        return _cache.getCachedBalance() != null;
      case OfflineFeature.viewTransactions:
        return _cache.getCachedTransactions() != null;
      case OfflineFeature.viewBeneficiaries:
        return _cache.getCachedBeneficiaries() != null;
      case OfflineFeature.generateReceiveQR:
        return _cache.getCachedWalletId() != null;
      case OfflineFeature.queueTransfer:
        return true; // Always available
    }
  }

  /// Get wallet ID for QR generation
  String? getWalletIdForQR() {
    return _cache.getCachedWalletId();
  }

  /// Update wallet ID
  Future<void> updateWalletId(String walletId) async {
    await _cache.cacheWalletId(walletId);
  }

  // ============================================================
  // Cache Management
  // ============================================================

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _cache.clearCache();
    await _queue.clearAll();
    await _ref.read(connectivityProvider.notifier).refreshPendingCount();
  }

  /// Check if any cached data exists
  bool hasCachedData() {
    return _cache.hasCachedData();
  }

  /// Get cache status
  CacheStatus getCacheStatus() {
    return CacheStatus(
      hasBalance: _cache.getCachedBalance() != null,
      hasTransactions: _cache.getCachedTransactions() != null,
      hasBeneficiaries: _cache.getCachedBeneficiaries() != null,
      hasWalletId: _cache.getCachedWalletId() != null,
      lastSync: _cache.getLastSync(),
    );
  }
}

/// Cached Data Wrapper
class CachedData<T> {
  final T data;
  final bool isCached;
  final DateTime? lastSync;

  const CachedData({
    required this.data,
    required this.isCached,
    this.lastSync,
  });

  bool get isStale {
    if (lastSync == null) return true;
    final age = DateTime.now().difference(lastSync!);
    return age.inMinutes > 5; // Consider stale after 5 minutes
  }
}

/// Offline Features
enum OfflineFeature {
  viewBalance,
  viewTransactions,
  viewBeneficiaries,
  generateReceiveQR,
  queueTransfer,
}

/// Cache Status
class CacheStatus {
  final bool hasBalance;
  final bool hasTransactions;
  final bool hasBeneficiaries;
  final bool hasWalletId;
  final DateTime? lastSync;

  const CacheStatus({
    required this.hasBalance,
    required this.hasTransactions,
    required this.hasBeneficiaries,
    required this.hasWalletId,
    this.lastSync,
  });

  bool get hasAnyCache =>
      hasBalance || hasTransactions || hasBeneficiaries || hasWalletId;
}

/// Offline Mode Manager Provider
final offlineModeManagerProvider = Provider<OfflineModeManager>((ref) {
  throw UnimplementedError('Must be overridden with dependencies');
});

/// Provider with dependencies
final offlineModeManagerFutureProvider =
    FutureProvider<OfflineModeManager>((ref) async {
  final cache = await ref.watch(offlineCacheServiceFutureProvider.future);
  final queue = await ref.watch(pendingTransferQueueFutureProvider.future);
  return OfflineModeManager(cache, queue, ref);
});
