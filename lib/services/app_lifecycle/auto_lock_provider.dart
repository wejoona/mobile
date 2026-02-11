/// Provider for auto-lock state management.
/// Tracks whether the app should show the lock screen on resume.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

/// Whether the app is currently locked and requires authentication.
final isAppLockedProvider = StateNotifierProvider<AppLockNotifier, bool>((ref) {
  return AppLockNotifier();
});

/// Controls the app lock state.
class AppLockNotifier extends StateNotifier<bool> {
  AppLockNotifier() : super(false);

  /// Lock the app (e.g. after background timeout).
  void lock() {
    state = true;
  }

  /// Unlock after successful authentication.
  void unlock() {
    state = false;
  }
}

/// User preference for auto-lock timeout in minutes.
final autoLockTimeoutProvider = StateProvider<int>((ref) => 5);

/// Whether auto-lock is enabled.
final autoLockEnabledProvider = StateProvider<bool>((ref) => true);
