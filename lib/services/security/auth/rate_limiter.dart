import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Client-side rate limiter for sensitive operations.
class RateLimiter {
  static const _tag = 'RateLimiter';
  final AppLogger _log = AppLogger(_tag);
  final Map<String, List<DateTime>> _attempts = {};

  /// Check if action is allowed within the rate limit.
  bool isAllowed(String action, {int maxAttempts = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final history = _attempts[action] ?? [];
    final recent = history.where((t) => now.difference(t) < window).toList();
    _attempts[action] = recent;

    if (recent.length >= maxAttempts) {
      _log.warn('Rate limit exceeded for $action');
      return false;
    }
    _attempts[action]!.add(now);
    return true;
  }

  /// Reset rate limit for an action.
  void reset(String action) {
    _attempts.remove(action);
  }

  /// Get remaining attempts.
  int remaining(String action, {int maxAttempts = 5, Duration window = const Duration(minutes: 1)}) {
    final now = DateTime.now();
    final recent = (_attempts[action] ?? []).where((t) => now.difference(t) < window).length;
    return (maxAttempts - recent).clamp(0, maxAttempts);
  }
}

final rateLimiterProvider = Provider<RateLimiter>((ref) {
  return RateLimiter();
});
