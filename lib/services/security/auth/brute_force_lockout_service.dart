import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../utils/logger.dart';

/// Lockout state for brute force protection.
class LockoutState {
  final int failedAttempts;
  final DateTime? lockedUntil;
  final bool isLocked;

  const LockoutState({
    this.failedAttempts = 0,
    this.lockedUntil,
    this.isLocked = false,
  });

  /// Remaining lockout duration, or null if not locked.
  Duration? get remainingLockout {
    if (lockedUntil == null) return null;
    final remaining = lockedUntil!.difference(DateTime.now());
    return remaining.isNegative ? null : remaining;
  }
}

/// Client-side brute force protection for PIN/password entry.
///
/// Implements progressive lockout: 3 failures = 30s, 5 = 5min, 7 = 30min, 10 = wipe.
/// Lockout state is persisted to survive app restarts.
class BruteForceLockoutService {
  static const _tag = 'BruteForceLockout';
  static const _prefAttempts = 'bf_attempts';
  static const _prefLockedUntil = 'bf_locked_until';
  final AppLogger _log = AppLogger(_tag);

  /// Maximum attempts before triggering data wipe.
  static const int maxAttemptsBeforeWipe = 10;

  /// Get current lockout state.
  Future<LockoutState> getState() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_prefAttempts) ?? 0;
    final lockedUntilMs = prefs.getInt(_prefLockedUntil);
    DateTime? lockedUntil;

    if (lockedUntilMs != null) {
      lockedUntil = DateTime.fromMillisecondsSinceEpoch(lockedUntilMs);
      if (DateTime.now().isAfter(lockedUntil)) {
        lockedUntil = null;
      }
    }

    return LockoutState(
      failedAttempts: attempts,
      lockedUntil: lockedUntil,
      isLocked: lockedUntil != null,
    );
  }

  /// Record a failed authentication attempt.
  /// Returns the new lockout state.
  Future<LockoutState> recordFailure() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt(_prefAttempts) ?? 0) + 1;
    await prefs.setInt(_prefAttempts, attempts);

    final lockoutDuration = _lockoutDuration(attempts);
    DateTime? lockedUntil;

    if (lockoutDuration != null) {
      lockedUntil = DateTime.now().add(lockoutDuration);
      await prefs.setInt(
          _prefLockedUntil, lockedUntil.millisecondsSinceEpoch);
      _log.debug('Account locked for ${lockoutDuration.inSeconds}s '
          'after $attempts failed attempts');
    }

    return LockoutState(
      failedAttempts: attempts,
      lockedUntil: lockedUntil,
      isLocked: lockedUntil != null,
    );
  }

  /// Reset on successful authentication.
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefAttempts);
    await prefs.remove(_prefLockedUntil);
  }

  /// Check if data wipe threshold is reached.
  Future<bool> shouldWipeData() async {
    final state = await getState();
    return state.failedAttempts >= maxAttemptsBeforeWipe;
  }

  Duration? _lockoutDuration(int attempts) {
    if (attempts >= 10) return const Duration(hours: 24);
    if (attempts >= 7) return const Duration(minutes: 30);
    if (attempts >= 5) return const Duration(minutes: 5);
    if (attempts >= 3) return const Duration(seconds: 30);
    return null;
  }
}

final bruteForceLockoutServiceProvider =
    Provider<BruteForceLockoutService>((ref) {
  return BruteForceLockoutService();
});
