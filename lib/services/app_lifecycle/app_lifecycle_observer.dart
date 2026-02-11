import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks app lifecycle for auto-lock, session expiry, and background tasks.
class AppLifecycleObserver extends WidgetsBindingObserver {
  final Ref _ref;
  DateTime? _backgroundedAt;

  /// Auto-lock threshold in minutes.
  static const int autoLockMinutes = 5;

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
        break;
      case AppLifecycleState.resumed:
        _onResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  void _onResumed() {
    if (_backgroundedAt != null) {
      final elapsed = DateTime.now().difference(_backgroundedAt!);
      if (kDebugMode) debugPrint('[Lifecycle] App resumed after ${elapsed.inSeconds}s');

      if (elapsed.inMinutes >= autoLockMinutes) {
        _triggerAutoLock();
      }
      _backgroundedAt = null;
    }
  }

  void _triggerAutoLock() {
    if (kDebugMode) debugPrint('[Lifecycle] Auto-lock triggered');
    // Navigate to PIN/biometric screen via router
    // This will be wired to GoRouter's redirect logic
  }

  /// Whether the app was recently backgrounded (within threshold).
  bool get wasRecentlyBackgrounded {
    if (_backgroundedAt == null) return false;
    return DateTime.now().difference(_backgroundedAt!).inMinutes < autoLockMinutes;
  }
}

final appLifecycleObserverProvider = Provider<AppLifecycleObserver>((ref) {
  final observer = AppLifecycleObserver(ref);
  observer.init();
  ref.onDispose(() => observer.dispose());
  return observer;
});
