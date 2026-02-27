import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/storage/hive_models.dart';
import 'package:usdc_wallet/services/storage/local_cache_service.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';
import 'package:usdc_wallet/services/transfers/transfers_service.dart';
import 'package:usdc_wallet/state/wallet_state_machine.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Max retries before marking as permanently failed
const int _maxRetries = 3;

/// Processes the offline pending operations queue.
/// Every financial action MUST be verified server-side.
class PendingOpsProcessor {
  final Ref _ref;
  final _log = AppLogger('PendingOpsProcessor');
  bool _isProcessing = false;

  PendingOpsProcessor(this._ref);

  LocalCacheService get _cache => _ref.read(localCacheServiceProvider);
  bool get _isOnline => _ref.read(isOnlineProvider);

  /// Process all pending operations sequentially
  Future<void> processAll() async {
    if (_isProcessing || !_isOnline || !_cache.isInitialized) return;
    _isProcessing = true;

    try {
      final ops = _cache.getProcessableOps();
      if (ops.isEmpty) return;

      _log.debug('Processing ${ops.length} pending operations');

      for (final op in ops) {
        if (!_isOnline) {
          _log.debug('Lost connectivity, stopping queue processing');
          break;
        }
        await _processOp(op);
      }
    } finally {
      _isProcessing = false;
    }
  }

  Future<void> _processOp(PendingOperation op) async {
    _log.debug('Processing op ${op.id} (type=${op.type}, retry=${op.retryCount})');

    // Mark as submitting
    op.status = 'submitting';
    await _cache.updatePendingOp(op);

    try {
      switch (op.type) {
        case 'send':
          await _processSend(op);
          break;
        case 'payment':
          await _processPayment(op);
          break;
        case 'withdrawal':
          await _processWithdrawal(op);
          break;
        default:
          _log.error('Unknown op type: ${op.type}');
          op.status = 'failed';
          op.lastError = 'Unknown operation type: ${op.type}';
          await _cache.updatePendingOp(op);
          return;
      }

      // Success — remove from queue
      await _cache.removePendingOp(op.id);
      _log.debug('Op ${op.id} completed successfully');

      // Refresh wallet balance
      try {
        await _ref.read(walletStateMachineProvider.notifier).refresh();
      } catch (_) {}
    } catch (e) {
      op.retryCount++;
      op.lastError = e.toString();

      if (op.retryCount >= _maxRetries) {
        op.status = 'failed';
        _log.error('Op ${op.id} permanently failed after $_maxRetries retries', e);
      } else {
        op.status = 'queued'; // Back to queue for retry
        _log.debug('Op ${op.id} failed (retry ${op.retryCount}/$_maxRetries): $e');
      }

      await _cache.updatePendingOp(op);
    }
  }

  Future<void> _processSend(PendingOperation op) async {
    if (op.pinToken == null || op.idempotencyKey == null) {
      throw Exception('Send op missing pinToken or idempotencyKey');
    }
    final transfersService = _ref.read(transfersServiceProvider);

    if (op.recipientPhone != null) {
      await transfersService.createInternalTransfer(
        recipientPhone: op.recipientPhone!,
        amount: op.amount,
        note: op.memo,
        pinToken: op.pinToken!,
        idempotencyKey: op.idempotencyKey!,
      );
    } else if (op.toAddress != null) {
      await transfersService.createExternalTransfer(
        recipientAddress: op.toAddress!,
        amount: op.amount,
        note: op.memo,
        pinToken: op.pinToken!,
        idempotencyKey: op.idempotencyKey!,
      );
    } else {
      throw Exception('Send op missing both recipientPhone and toAddress');
    }
  }

  Future<void> _processPayment(PendingOperation op) async {
    if (op.pinToken == null || op.idempotencyKey == null) {
      throw Exception('Payment op missing pinToken or idempotencyKey');
    }
    final transfersService = _ref.read(transfersServiceProvider);
    if (op.recipientPhone != null) {
      await transfersService.createInternalTransfer(
        recipientPhone: op.recipientPhone!,
        amount: op.amount,
        note: op.memo,
        pinToken: op.pinToken!,
        idempotencyKey: op.idempotencyKey!,
      );
    }
  }

  Future<void> _processWithdrawal(PendingOperation op) async {
    if (op.pinToken == null || op.idempotencyKey == null) {
      throw Exception('Withdrawal op missing pinToken or idempotencyKey');
    }
    final transfersService = _ref.read(transfersServiceProvider);
    if (op.toAddress != null) {
      await transfersService.createExternalTransfer(
        recipientAddress: op.toAddress!,
        amount: op.amount,
        note: op.memo,
        pinToken: op.pinToken!,
        idempotencyKey: op.idempotencyKey!,
      );
    } else {
      throw Exception('Withdrawal op missing toAddress');
    }
  }
}

final pendingOpsProcessorProvider = Provider<PendingOpsProcessor>((ref) {
  return PendingOpsProcessor(ref);
});
