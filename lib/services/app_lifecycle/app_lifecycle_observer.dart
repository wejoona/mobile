import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/state/fsm/session_fsm.dart';
import 'package:usdc_wallet/state/fsm/app_fsm.dart';

/// Tracks app lifecycle for auto-lock, session expiry, and background tasks.
class AppLifecycleObserver extends WidgetsBindingObserver {
  final Ref _ref;
  DateTime? _backgroundedAt;

  AppLifecycleObserver(this._ref);

  void init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = DateTime.now();
        if (kDebugMode) debugPrint('[Lifecycle] App backgrounded');
        // Lock immediately when going to background
        _triggerAutoLock();
        break;
      case AppLifecycleState.resumed:
        if (kDebugMode) {
          final elapsed = _backgroundedAt != null
              ? DateTime.now().difference(_backgroundedAt!).inSeconds
              : 0;
          debugPrint('[Lifecycle] App resumed after ${elapsed}s');
        }
        _backgroundedAt = null;
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _triggerAutoLock() {
    // Only lock if authenticated
    final appState = _ref.read(appFsmProvider);
    if (!appState.isAuthenticated) return;

    if (kDebugMode) debugPrint('[Lifecycle] Auto-lock triggered');
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
