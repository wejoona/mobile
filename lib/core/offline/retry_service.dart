import 'dart:async';
import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/connectivity/connectivity_provider.dart';

/// Retry Strategy
enum RetryStrategy {
  /// Exponential backoff: 1s, 2s, 4s, 8s, 16s
  exponential,

  /// Linear backoff: 1s, 2s, 3s, 4s, 5s
  linear,

  /// Immediate retry (no delay)
  immediate,

  /// Fixed interval: 5s between retries
  fixed,
}

/// Retry Configuration
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxAttempts;

  /// Retry strategy to use
  final RetryStrategy strategy;

  /// Initial delay in seconds
  final int initialDelaySeconds;

  /// Maximum delay between retries (for exponential)
  final int maxDelaySeconds;

  /// Whether to only retry when online
  final bool requiresOnline;

  const RetryConfig({
    this.maxAttempts = 3,
    this.strategy = RetryStrategy.exponential,
    this.initialDelaySeconds = 1,
    this.maxDelaySeconds = 30,
    this.requiresOnline = true,
  });

  /// Default config for API calls
  static const RetryConfig api = RetryConfig(
    maxAttempts: 3,
    strategy: RetryStrategy.exponential,
    initialDelaySeconds: 1,
    maxDelaySeconds: 10,
    requiresOnline: true,
  );

  /// Config for critical operations (more aggressive)
  static const RetryConfig critical = RetryConfig(
    maxAttempts: 5,
    strategy: RetryStrategy.exponential,
    initialDelaySeconds: 1,
    maxDelaySeconds: 30,
    requiresOnline: true,
  );

  /// Config for background sync (less aggressive)
  static const RetryConfig background = RetryConfig(
    maxAttempts: 3,
    strategy: RetryStrategy.fixed,
    initialDelaySeconds: 5,
    maxDelaySeconds: 60,
    requiresOnline: true,
  );

  /// Config for immediate operations (no delay)
  static const RetryConfig immediate = RetryConfig(
    maxAttempts: 2,
    strategy: RetryStrategy.immediate,
    initialDelaySeconds: 0,
    maxDelaySeconds: 0,
    requiresOnline: false,
  );
}

/// Retry Result
class RetryResult<T> {
  final T? data;
  final bool success;
  final int attempts;
  final String? error;

  const RetryResult({
    this.data,
    required this.success,
    required this.attempts,
    this.error,
  });

  factory RetryResult.success(T data, int attempts) {
    return RetryResult(
      data: data,
      success: true,
      attempts: attempts,
    );
  }

  factory RetryResult.failure(String error, int attempts) {
    return RetryResult(
      success: false,
      attempts: attempts,
      error: error,
    );
  }
}

/// Retry Service
/// Handles automatic retry logic for failed operations
class RetryService {
  final Ref _ref;

  RetryService(this._ref);

  /// Execute an operation with automatic retry
  Future<RetryResult<T>> execute<T>({
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.api,
    String? operationName,
  }) async {
    int attempts = 0;
    String? lastError;

    while (attempts < config.maxAttempts) {
      attempts++;

      // Check if online (if required)
      if (config.requiresOnline) {
        final isOnline = _ref.read(isOnlineProvider);
        if (!isOnline) {
          // Wait for connection before retrying
          await _waitForConnection();
        }
      }

      try {
        final result = await operation();
        return RetryResult.success(result, attempts);
      } catch (e) {
        lastError = e.toString();

        // Don't delay on last attempt
        if (attempts < config.maxAttempts) {
          final delay = _calculateDelay(attempts, config);
          await Future.delayed(Duration(seconds: delay));
        }
      }
    }

    return RetryResult.failure(
      lastError ?? 'Operation failed after $attempts attempts',
      attempts,
    );
  }

  /// Execute an operation and return data or throw
  Future<T> executeOrThrow<T>({
    required Future<T> Function() operation,
    RetryConfig config = RetryConfig.api,
    String? operationName,
  }) async {
    final result = await execute(
      operation: operation,
      config: config,
      operationName: operationName,
    );

    if (result.success && result.data != null) {
      return result.data!;
    } else {
      throw Exception(result.error ?? 'Operation failed');
    }
  }

  /// Calculate delay based on retry strategy
  int _calculateDelay(int attempt, RetryConfig config) {
    final delay = switch (config.strategy) {
      RetryStrategy.exponential => _exponentialDelay(attempt, config),
      RetryStrategy.linear => _linearDelay(attempt, config),
      RetryStrategy.fixed => config.initialDelaySeconds,
      RetryStrategy.immediate => 0,
    };

    return delay.clamp(0, config.maxDelaySeconds);
  }

  /// Calculate exponential backoff delay
  int _exponentialDelay(int attempt, RetryConfig config) {
    // 2^(attempt-1) * initialDelay
    // Attempt 1: 1s, Attempt 2: 2s, Attempt 3: 4s, etc.
    final multiplier = 1 << (attempt - 1); // 2^(attempt-1)
    return config.initialDelaySeconds * multiplier;
  }

  /// Calculate linear backoff delay
  int _linearDelay(int attempt, RetryConfig config) {
    // attempt * initialDelay
    // Attempt 1: 1s, Attempt 2: 2s, Attempt 3: 3s, etc.
    return config.initialDelaySeconds * attempt;
  }

  /// Wait for connection to be restored
  Future<void> _waitForConnection() async {
    final completer = Completer<void>();

    // Check current state
    final currentState = _ref.read(connectivityProvider);
    if (currentState.isOnline) {
      return;
    }

    // Wait for timeout (polling-based fallback)
    await Future.delayed(const Duration(seconds: 30));
  }
}

/// Retry Service Provider
final retryServiceProvider = Provider<RetryService>((ref) {
  return RetryService(ref);
});

/// Retry Extension for Future
extension RetryExtension<T> on Future<T> {
  /// Retry this future with the given config
  Future<T> withRetry(
    WidgetRef ref, {
    RetryConfig config = RetryConfig.api,
  }) async {
    final retryService = ref.read(retryServiceProvider);
    return retryService.executeOrThrow(
      operation: () => this,
      config: config,
    );
  }
}

/// Auto Retry Queue
/// Manages a queue of operations that should be retried automatically
class AutoRetryQueue {
  final Ref _ref;
  final List<_QueuedOperation> _queue = [];
  bool _isProcessing = false;

  AutoRetryQueue(this._ref);

  /// Add an operation to the retry queue
  void enqueue({
    required String id,
    required Future<void> Function() operation,
    RetryConfig config = RetryConfig.api,
    VoidCallback? onSuccess,
    void Function(String error)? onFailure,
  }) {
    // Remove existing operation with same ID
    _queue.removeWhere((op) => op.id == id);

    // Add new operation
    _queue.add(_QueuedOperation(
      id: id,
      operation: operation,
      config: config,
      onSuccess: onSuccess,
      onFailure: onFailure,
    ));

    // Start processing if not already running
    _processQueue();
  }

  /// Remove an operation from the queue
  void remove(String id) {
    _queue.removeWhere((op) => op.id == id);
  }

  /// Clear all operations
  void clear() {
    _queue.clear();
  }

  /// Get number of pending operations
  int get pendingCount => _queue.length;

  /// Process the retry queue
  Future<void> _processQueue() async {
    if (_isProcessing || _queue.isEmpty) return;

    _isProcessing = true;

    while (_queue.isNotEmpty) {
      final op = _queue.first;
      final retryService = _ref.read(retryServiceProvider);

      final result = await retryService.execute(
        operation: op.operation,
        config: op.config,
      );

      // Remove from queue
      _queue.removeAt(0);

      // Call callbacks
      if (result.success) {
        op.onSuccess?.call();
      } else {
        op.onFailure?.call(result.error ?? 'Unknown error');
      }
    }

    _isProcessing = false;
  }

  /// Manually trigger queue processing
  Future<void> processNow() async {
    await _processQueue();
  }
}

/// Queued Operation
class _QueuedOperation {
  final String id;
  final Future<void> Function() operation;
  final RetryConfig config;
  final VoidCallback? onSuccess;
  final void Function(String error)? onFailure;

  _QueuedOperation({
    required this.id,
    required this.operation,
    required this.config,
    this.onSuccess,
    this.onFailure,
  });
}

/// Auto Retry Queue Provider
final autoRetryQueueProvider = Provider<AutoRetryQueue>((ref) {
  return AutoRetryQueue(ref);
});
