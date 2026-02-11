import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/offline/pending_transfer_queue.dart';

/// Connectivity State
class ConnectivityState {
  final bool isOnline;
  final bool isProcessingQueue;
  final int pendingCount;
  final DateTime? lastSync;

  const ConnectivityState({
    this.isOnline = true,
    this.isProcessingQueue = false,
    this.pendingCount = 0,
    this.lastSync,
  });

  ConnectivityState copyWith({
    bool? isOnline,
    bool? isProcessingQueue,
    int? pendingCount,
    DateTime? lastSync,
  }) {
    return ConnectivityState(
      isOnline: isOnline ?? this.isOnline,
      isProcessingQueue: isProcessingQueue ?? this.isProcessingQueue,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSync: lastSync ?? this.lastSync,
    );
  }
}

/// Connectivity Notifier
/// Monitors network connectivity and manages offline queue processing
class ConnectivityNotifier extends Notifier<ConnectivityState> {
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  PendingTransferQueue? _queue;

  @override
  ConnectivityState build() {
    // Initialize connectivity monitoring
    _initConnectivity();

    // Cleanup on dispose
    ref.onDispose(() {
      _subscription?.cancel();
    });

    return const ConnectivityState();
  }

  /// Initialize connectivity monitoring
  Future<void> _initConnectivity() async {
    final connectivity = Connectivity();

    // Get initial state
    final result = await connectivity.checkConnectivity();
    final isOnline = _isConnected(result);
    state = state.copyWith(isOnline: isOnline);

    // Load pending count
    await _loadPendingCount();

    // Listen for changes
    _subscription = connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = state.isOnline;
      final isNowOnline = _isConnected(results);

      state = state.copyWith(isOnline: isNowOnline);

      // Process queue when going from offline to online
      if (!wasOnline && isNowOnline) {
        _processQueue();
      }
    });
  }

  /// Check if any connectivity result indicates connection
  bool _isConnected(List<ConnectivityResult> results) {
    return results.any((result) =>
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet
    );
  }

  /// Load pending transfer count
  Future<void> _loadPendingCount() async {
    try {
      final queueAsyncValue = ref.read(pendingTransferQueueFutureProvider);
      // Get the value from AsyncValue
      _queue = queueAsyncValue.when(
        data: (queue) => queue,
        loading: () => null,
        error: (_, __) => null,
      );
      final count = _queue?.getPendingCount() ?? 0;
      state = state.copyWith(pendingCount: count);
    } catch (e) {
      // Ignore errors during initialization
    }
  }

  /// Refresh pending count manually
  Future<void> refreshPendingCount() async {
    await _loadPendingCount();
  }

  /// Process pending transfers queue
  Future<void> _processQueue() async {
    if (state.isProcessingQueue || _queue == null) return;

    state = state.copyWith(isProcessingQueue: true);

    try {
      final transfers = _queue!.getTransfersToProcess();

      for (final transfer in transfers) {
        try {
          await _queue!.markProcessing(transfer.id);

          // TODO: Process transfer via SDK
          // final sdk = ref.read(sdkProvider);
          // await sdk.transfers.send(...);

          await _queue!.markCompleted(transfer.id);
        } catch (e) {
          await _queue!.markFailed(transfer.id, e.toString());
        }
      }

      // Update pending count
      await _loadPendingCount();

      // Update last sync time
      state = state.copyWith(
        lastSync: DateTime.now(),
      );
    } finally {
      state = state.copyWith(isProcessingQueue: false);
    }
  }

  /// Manually trigger queue processing
  Future<void> processQueueManually() async {
    if (!state.isOnline) return;
    await _processQueue();
  }

  /// Update last sync time
  void updateLastSync() {
    state = state.copyWith(lastSync: DateTime.now());
  }
}

/// Connectivity Provider
final connectivityProvider = NotifierProvider<ConnectivityNotifier, ConnectivityState>(
  ConnectivityNotifier.new,
);

/// Convenience provider for online status
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).isOnline;
});

/// Convenience provider for pending count
final pendingCountProvider = Provider<int>((ref) {
  return ref.watch(connectivityProvider).pendingCount;
});
