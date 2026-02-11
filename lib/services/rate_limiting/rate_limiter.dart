import 'dart:collection';

/// Run 374: Rate limiter service for API calls and user actions
class RateLimiter {
  final int maxRequests;
  final Duration window;
  final Queue<DateTime> _timestamps = Queue();

  RateLimiter({
    required this.maxRequests,
    required this.window,
  });

  bool get canProceed {
    _cleanUp();
    return _timestamps.length < maxRequests;
  }

  int get remainingRequests {
    _cleanUp();
    return maxRequests - _timestamps.length;
  }

  Duration? get retryAfter {
    if (canProceed) return null;
    if (_timestamps.isEmpty) return null;
    final oldest = _timestamps.first;
    final expiry = oldest.add(window);
    final remaining = expiry.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }

  bool tryAcquire() {
    _cleanUp();
    if (_timestamps.length >= maxRequests) return false;
    _timestamps.add(DateTime.now());
    return true;
  }

  void _cleanUp() {
    final cutoff = DateTime.now().subtract(window);
    while (_timestamps.isNotEmpty && _timestamps.first.isBefore(cutoff)) {
      _timestamps.removeFirst();
    }
  }

  void reset() {
    _timestamps.clear();
  }
}

/// Pre-configured rate limiters for common operations
class RateLimiters {
  RateLimiters._();

  /// OTP requests: max 3 per 5 minutes
  static final otp = RateLimiter(
    maxRequests: 3,
    window: const Duration(minutes: 5),
  );

  /// Transfer confirmations: max 10 per minute
  static final transfer = RateLimiter(
    maxRequests: 10,
    window: const Duration(minutes: 1),
  );

  /// PIN attempts: max 5 per 15 minutes
  static final pin = RateLimiter(
    maxRequests: 5,
    window: const Duration(minutes: 15),
  );

  /// API general: max 60 per minute
  static final api = RateLimiter(
    maxRequests: 60,
    window: const Duration(minutes: 1),
  );
}
