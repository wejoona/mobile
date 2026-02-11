import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_service.dart';
import 'package:usdc_wallet/services/offline/offline_cache_service.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';
import 'package:usdc_wallet/services/sdk/usdc_wallet_sdk.dart';
import 'package:usdc_wallet/state/app_state.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/state/transaction_state_machine.dart';
import 'package:usdc_wallet/features/beneficiaries/providers/beneficiaries_provider.dart';

/// Offline State
class OfflineState {
  final bool isOnline;
  final bool isSyncing;
  final int pendingTransferCount;
  final DateTime? lastSync;
  final String? syncError;

  const OfflineState({
    this.isOnline = true,
    this.isSyncing = false,
    this.pendingTransferCount = 0,
    this.lastSync,
    this.syncError,
  });

  OfflineState copyWith({
    bool? isOnline,
    bool? isSyncing,
    int? pendingTransferCount,
    DateTime? lastSync,
    String? syncError,
  }) {
    return OfflineState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingTransferCount: pendingTransferCount ?? this.pendingTransferCount,
      lastSync: lastSync ?? this.lastSync,
      syncError: syncError,
    );
  }
}

/// Offline Provider
/// Manages offline mode, caching, and sync operations
class OfflineNotifier extends Notifier<OfflineState> {
  OfflineCacheService? _cacheService;
  PendingTransferQueue? _queue;

  @override
  OfflineState build() {
    _initialize();
    return const OfflineState();
  }

  Future<void> _initialize() async {
    // Initialize services
    final cacheServiceAsync = await ref.read(offlineCacheServiceFutureProvider.future);
    _cacheService = cacheServiceAsync;

    final queueAsync = await ref.read(pendingTransferQueueFutureProvider.future);
    _queue = queueAsync;

    // Load initial state
    final lastSync = _cacheService?.getLastSync();
    final pendingCount = _queue?.getPendingCount() ?? 0;

    state = state.copyWith(
      lastSync: lastSync,
      pendingTransferCount: pendingCount,
    );

    // Listen to connectivity changes
    ref.listen(connectivityStatusProvider, (previous, next) {
      next.when(
        data: (status) => _handleConnectivityChange(status),
        loading: () {},
        error: (_, __) {},
      );
    });
  }

  // ============================================================
  // Connectivity Handling
  // ============================================================

  void _handleConnectivityChange(ConnectivityStatus status) {
    final wasOffline = !state.isOnline;
    final isNowOnline = status == ConnectivityStatus.online;

    state = state.copyWith(isOnline: isNowOnline);

    // Trigger sync when coming back online
    if (wasOffline && isNowOnline) {
      syncWhenOnline();
    }
  }

  // ============================================================
  // Caching Operations
  // ============================================================

  /// Cache wallet data
  Future<void> cacheWalletData({
    double? balance,
    String? walletId,
  }) async {
    if (_cacheService == null) return;

    if (balance != null) {
      await _cacheService!.cacheBalance(balance);
    }

    if (walletId != null) {
      await _cacheService!.cacheWalletId(walletId);
    }

    state = state.copyWith(lastSync: DateTime.now());
  }

  /// Get cached balance
  double? getCachedBalance() {
    return _cacheService?.getCachedBalance();
  }

  // ============================================================
  // Queue Operations
  // ============================================================

  /// Add transfer to pending queue
  Future<String> queueTransfer({
    required String recipientPhone,
    String? recipientName,
    required double amount,
    String? description,
  }) async {
    if (_queue == null) throw Exception('Queue not initialized');

    final transfer = PendingTransfer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      recipientPhone: recipientPhone,
      recipientName: recipientName,
      amount: amount,
      description: description,
      timestamp: DateTime.now(),
    );

    await _queue!.enqueue(transfer);

    state = state.copyWith(
      pendingTransferCount: _queue!.getPendingCount(),
    );

    return transfer.id;
  }

  /// Get pending transfers
  List<PendingTransfer> getPendingTransfers() {
    return _queue?.getQueue() ?? [];
  }

  // ============================================================
  // Sync Operations
  // ============================================================

  /// Sync data when online
  Future<void> syncWhenOnline() async {
    if (!state.isOnline || state.isSyncing) return;

    state = state.copyWith(isSyncing: true, syncError: null);

    try {
      // 1. Process pending transfers
      await _processPendingTransfers();

      // 2. Refresh wallet data
      await _refreshWalletData();

      // 3. Update sync timestamp
      state = state.copyWith(
        isSyncing: false,
        lastSync: DateTime.now(),
        pendingTransferCount: _queue?.getPendingCount() ?? 0,
      );
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        syncError: e.toString(),
      );
    }
  }

  /// Process pending transfers
  Future<void> _processPendingTransfers() async {
    if (_queue == null) return;

    final transfersToProcess = _queue!.getTransfersToProcess();

    for (final transfer in transfersToProcess) {
      try {
        await _queue!.markProcessing(transfer.id);

        // Execute transfer via SDK
        final sdk = ref.read(sdkProvider);
        await sdk.transfers.createInternalTransfer(
          recipientPhone: transfer.recipientPhone,
          amount: transfer.amount,
          note: transfer.description,
        );

        await _queue!.markCompleted(transfer.id);
      } catch (e) {
        await _queue!.markFailed(transfer.id, e.toString());
      }
    }

    // Clean up old completed transfers
    await _queue!.clearCompleted(olderThanDays: 7);
  }

  /// Refresh wallet data and cache it
  Future<void> _refreshWalletData() async {
    // Refresh wallet state
    await ref.read(walletStateMachineProvider.notifier).refresh();

    // Refresh transactions
    await ref.read(transactionStateMachineProvider.notifier).refresh();

    // Cache the fresh data
    final walletState = ref.read(walletStateMachineProvider);
    if (walletState.status == WalletStatus.loaded) {
      await cacheWalletData(
        balance: walletState.usdcBalance,
        walletId: walletState.walletId,
      );
    }

    // Cache transactions
    final txState = ref.read(transactionStateMachineProvider);
    if (txState.status == TransactionListStatus.loaded &&
        _cacheService != null) {
      await _cacheService!.cacheTransactions(txState.transactions);
    }

    // Cache beneficiaries
    final beneficiariesState = ref.read(beneficiariesProvider);
    if (!beneficiariesState.isLoading && _cacheService != null) {
      await _cacheService!.cacheBeneficiaries(beneficiariesState.beneficiaries);
    }
  }

  // ============================================================
  // Manual Operations
  // ============================================================

  /// Manually trigger sync
  Future<void> manualSync() async {
    await syncWhenOnline();
  }

  /// Clear offline cache
  Future<void> clearCache() async {
    await _cacheService?.clearCache();
    state = state.copyWith(lastSync: null);
  }

  /// Retry failed transfer
  Future<void> retryFailedTransfer(String transferId) async {
    if (_queue == null || !state.isOnline) return;

    await _queue!.updateTransferStatus(transferId, TransferStatus.pending);
    state = state.copyWith(
      pendingTransferCount: _queue!.getPendingCount(),
    );

    await _processPendingTransfers();
  }

  /// Cancel pending transfer
  Future<void> cancelPendingTransfer(String transferId) async {
    if (_queue == null) return;

    await _queue!.removeTransfer(transferId);
    state = state.copyWith(
      pendingTransferCount: _queue!.getPendingCount(),
    );
  }
}

/// Offline Provider
final offlineProvider = NotifierProvider<OfflineNotifier, OfflineState>(
  OfflineNotifier.new,
);
