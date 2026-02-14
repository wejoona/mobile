import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Persists lockout state across app restarts.
class LockoutState {
  final int failedAttempts;
  final DateTime? lockedUntil;
  final DateTime? lastAttempt;

  const LockoutState({
    this.failedAttempts = 0,
    this.lockedUntil,
    this.lastAttempt,
  });

  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  Duration get remainingLockout =>
      isLocked ? lockedUntil!.difference(DateTime.now()) : Duration.zero;

  LockoutState copyWith({
    int? failedAttempts,
    DateTime? lockedUntil,
    DateTime? lastAttempt,
  }) {
    return LockoutState(
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      lastAttempt: lastAttempt ?? this.lastAttempt,
    );
  }
}

class LockoutStateNotifier extends StateNotifier<LockoutState> {
  static const _tag = 'LockoutState';
  final AppLogger _log = AppLogger(_tag);

  LockoutStateNotifier() : super(const LockoutState());

  void recordFailure() {
    final attempts = state.failedAttempts + 1;
    DateTime? lockUntil;
    if (attempts >= 5) {
      lockUntil = DateTime.now().add(Duration(minutes: attempts * 2));
      _log.warn('Account locked for ${attempts * 2} minutes');
    }
    state = state.copyWith(
      failedAttempts: attempts,
      lockedUntil: lockUntil,
      lastAttempt: DateTime.now(),
    );
  }

  void reset() {
    state = const LockoutState();
  }
}

final lockoutStateProvider =
    StateNotifierProvider<LockoutStateNotifier, LockoutState>((ref) {
  return LockoutStateNotifier();
});
