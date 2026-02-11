import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Configurable retry policy for failed requests.
class RequestRetryPolicy {
  static const _tag = 'RetryPolicy';
  final AppLogger _log = AppLogger(_tag);
  final int maxRetries;
  final Duration baseDelay;

  RequestRetryPolicy({this.maxRetries = 3, this.baseDelay = const Duration(seconds: 1)});

  /// Calculate delay for attempt number (exponential backoff).
  Duration getDelay(int attempt) {
    final multiplier = 1 << attempt; // 2^attempt
    return baseDelay * multiplier;
  }

  /// Check if the status code is retryable.
  bool isRetryable(int statusCode) {
    return statusCode == 429 || statusCode >= 500;
  }

  /// Should retry this attempt?
  bool shouldRetry(int attempt, int statusCode) {
    return attempt < maxRetries && isRetryable(statusCode);
  }
}

final requestRetryPolicyProvider = Provider<RequestRetryPolicy>((ref) {
  return RequestRetryPolicy();
});
