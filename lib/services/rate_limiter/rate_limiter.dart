/// Client-side rate limiter to prevent API spam.
class RateLimiter {
  final int maxCalls;
  final Duration window;
  final List<DateTime> _timestamps = [];

  RateLimiter({
    required this.maxCalls,
    required this.window,
  });

  /// Check if an action is allowed. Returns true if within rate limit.
  bool tryAcquire() {
    _cleanup();
    if (_timestamps.length >= maxCalls) return false;
    _timestamps.add(DateTime.now());
    return true;
  }

  /// Execute [action] if within rate limit, otherwise return null.
  Future<T?> execute<T>(Future<T> Function() action) async {
    if (!tryAcquire()) return null;
    return action();
  }

  /// Time until next allowed call, or Duration.zero if allowed now.
  Duration get waitTime {
    _cleanup();
    if (_timestamps.length < maxCalls) return Duration.zero;
    final oldest = _timestamps.first;
    final available = oldest.add(window);
    final now = DateTime.now();
    return available.isAfter(now) ? available.difference(now) : Duration.zero;
  }

  /// Remaining calls in current window.
  int get remaining {
    _cleanup();
    return (maxCalls - _timestamps.length).clamp(0, maxCalls);
  }

  /// Reset the rate limiter.
  void reset() => _timestamps.clear();

  void _cleanup() {
    final cutoff = DateTime.now().subtract(window);
    _timestamps.removeWhere((t) => t.isBefore(cutoff));
  }
}

/// Pre-configured rate limiters for common operations.
class AppRateLimiters {
  AppRateLimiters._();

  /// Transfer: max 5 per minute.
  static final transfer = RateLimiter(
    maxCalls: 5,
    window: const Duration(minutes: 1),
  );

  /// OTP request: max 3 per 5 minutes.
  static final otpRequest = RateLimiter(
    maxCalls: 3,
    window: const Duration(minutes: 5),
  );

  /// PIN attempt: max 5 per 15 minutes.
  static final pinAttempt = RateLimiter(
    maxCalls: 5,
    window: const Duration(minutes: 15),
  );

  /// Search: max 10 per minute.
  static final search = RateLimiter(
    maxCalls: 10,
    window: const Duration(minutes: 1),
  );
}
