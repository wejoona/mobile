import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';
import 'package:usdc_wallet/services/realtime/realtime_service.dart';

/// Grace period before locking — covers camera, image picker, biometric prompts.
const _lockGracePeriod = Duration(seconds: 60);

/// Tracks app lifecycle for auto-lock, session expiry, and background tasks.
class AppLifecycleObserver extends WidgetsBindingObserver {
  final Ref _ref;
  DateTime? _backgroundedAt;
  Timer? _lockTimer;

  AppLifecycleObserver(this._ref);

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    _lockTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = DateTime.now();
        if (kDebugMode) debugPrint('[Lifecycle] App backgrounded');
        // Pause realtime while backgrounded
        try { _ref.read(realtimeServiceProvider).pause(); } catch (_) {}
        // Start grace timer — don't lock immediately (camera/picker/biometric)
        _startLockTimer();
        break;
      case AppLifecycleState.resumed:
        // Cancel pending lock if we came back within grace period
        _lockTimer?.cancel();
        _lockTimer = null;
        if (kDebugMode) {
          final elapsed = _backgroundedAt != null
              ? DateTime.now().difference(_backgroundedAt!).inSeconds
              : 0;
          debugPrint('[Lifecycle] App resumed after ${elapsed}s');
        }
        _backgroundedAt = null;
        // Resume realtime + immediate pull when foregrounded
        try { _ref.read(realtimeServiceProvider).resume(); } catch (_) {}
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel();
    _lockTimer = Timer(_lockGracePeriod, () {
      _triggerAutoLock();
    });
  }

  void _triggerAutoLock() {
    // Only lock if authenticated
    final appState = _ref.read(appFsmProvider);
    if (!appState.isAuthenticated) return;

    if (kDebugMode) debugPrint('[Lifecycle] Auto-lock triggered after grace period');
    _ref.read(appFsmProvider.notifier).dispatch(
          const AppSessionEvent(SessionLock(reason: 'App backgrounded')),
        );
  }
}

final appLifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  final observer = AppLifecycleObserver(ref);
  observer.init();
  ref.onDispose(() => observer.dispose());
  return observer;
});
