import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/notifications/providers/notifications_provider.dart';
import 'package:usdc_wallet/features/transactions/providers/transactions_provider.dart';
import 'package:usdc_wallet/features/wallet/providers/balance_provider.dart';
import 'package:usdc_wallet/state/user_state_machine.dart';

/// A pending write operation that failed and needs retrying.
class _PendingAction {
  final String id;
  final Future<void> Function() execute;
  int attempts = 0;

  _PendingAction({required this.id, required this.execute});
}

/// POP3/SMTP-style sync service.
///
/// **Pull:** Periodic polling (every [pollInterval]) plus manual triggers.
/// **Push:** Queues failed writes and retries them on the next pull cycle.
class SyncService {
  final Ref _ref;

  Timer? _pollTimer;
  bool _polling = false;
  bool _disposed = false;

  /// How often to poll when the app is active.
  static const pollInterval = Duration(seconds: 30);

  /// Max retry attempts for a pending push action.
  static const _maxPushAttempts = 5;

  /// Queue of failed writes to retry.
  final _pendingActions = Queue<_PendingAction>();

  SyncService(this._ref);

  // ---------------------------------------------------------------------------
  // Polling lifecycle
  // ---------------------------------------------------------------------------

  /// Begin periodic polling.
  void startPolling() {
    if (_disposed) return;
    stopPolling(); // idempotent
    if (kDebugMode) debugPrint('[Sync] Polling started (${pollInterval.inSeconds}s)');
    _pollTimer = Timer.periodic(pollInterval, (_) => _tick());
  }

  /// Stop periodic polling.
  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  /// Full pull + push cycle (also used as the timer callback).
  Future<void> _tick() async {
    if (_polling || _disposed) return;
    _polling = true;
    try {
      await pullAll();
      await pushPending();
    } finally {
      _polling = false;
    }
  }

  // ---------------------------------------------------------------------------
  // PULL — fetch fresh data from the backend
  // ---------------------------------------------------------------------------

  /// Invalidate all major providers so Riverpod re-fetches them.
  Future<void> pullAll() async {
    if (_disposed) return;
    if (kDebugMode) debugPrint('[Sync] pullAll');

    _ref.invalidate(walletBalanceProvider);
    _ref.invalidate(transactionsProvider);
    _ref.invalidate(notificationsProvider);
    _ref.invalidate(userStateMachineProvider);
  }

  // ---------------------------------------------------------------------------
  // PUSH — flush queued writes
  // ---------------------------------------------------------------------------

  /// Enqueue a write that should be retried if it fails.
  ///
  /// [id] is a dedup key — adding the same id replaces the previous entry.
  void enqueuePush(String id, Future<void> Function() action) {
    // Remove existing entry with the same id (replace semantics).
    _pendingActions.removeWhere((a) => a.id == id);
    _pendingActions.add(_PendingAction(id: id, execute: action));
    if (kDebugMode) {
      debugPrint('[Sync] Enqueued push "$id" (queue: ${_pendingActions.length})');
    }
  }

  /// Attempt to flush all pending push actions.
  Future<void> pushPending() async {
    if (_pendingActions.isEmpty || _disposed) return;
    if (kDebugMode) {
      debugPrint('[Sync] pushPending — ${_pendingActions.length} item(s)');
    }

    final failed = <_PendingAction>[];

    while (_pendingActions.isNotEmpty) {
      final action = _pendingActions.removeFirst();
      action.attempts++;
      try {
        await action.execute();
        if (kDebugMode) debugPrint('[Sync] Push "${action.id}" succeeded');
      } catch (e) {
        if (action.attempts < _maxPushAttempts) {
          failed.add(action);
          if (kDebugMode) {
            debugPrint(
              '[Sync] Push "${action.id}" failed (attempt ${action.attempts}/$_maxPushAttempts): $e',
            );
          }
        } else {
          if (kDebugMode) {
            debugPrint('[Sync] Push "${action.id}" dropped after $_maxPushAttempts attempts');
          }
        }
      }
    }

    // Re-enqueue failures for next cycle.
    _pendingActions.addAll(failed);
  }

  // ---------------------------------------------------------------------------
  // Convenience triggers
  // ---------------------------------------------------------------------------

  /// Called when the app comes back to the foreground.
  Future<void> syncOnResume() async {
    if (kDebugMode) debugPrint('[Sync] syncOnResume');
    await _tick();
  }

  /// Called after a user-initiated transaction completes.
  Future<void> syncAfterTransaction() async {
    if (kDebugMode) debugPrint('[Sync] syncAfterTransaction');
    _ref.invalidate(walletBalanceProvider);
    _ref.invalidate(transactionsProvider);
  }

  // ---------------------------------------------------------------------------
  // Cleanup
  // ---------------------------------------------------------------------------

  void dispose() {
    _disposed = true;
    stopPolling();
    _pendingActions.clear();
    if (kDebugMode) debugPrint('[Sync] Disposed');
  }
}
