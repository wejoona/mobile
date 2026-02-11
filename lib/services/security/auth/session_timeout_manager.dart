import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Gère l'expiration automatique des sessions.
class SessionTimeoutManager {
  static const _tag = 'SessionTimeout';
  final AppLogger _log = AppLogger(_tag);
  Timer? _timer;
  final Duration timeout;
  final VoidCallback? onTimeout;

  SessionTimeoutManager({
    this.timeout = const Duration(minutes: 15),
    this.onTimeout,
  });

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(timeout, () {
      _log.debug('Session timed out after ${timeout.inMinutes} minutes');
      onTimeout?.call();
    });
  }

  void resetTimer() {
    if (_timer?.isActive ?? false) {
      startTimer();
    }
  }

  void stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isActive => _timer?.isActive ?? false;

  void dispose() {
    _timer?.cancel();
  }
}

typedef VoidCallback = void Function();

final sessionTimeoutManagerProvider = Provider<SessionTimeoutManager>((ref) {
  final manager = SessionTimeoutManager();
  ref.onDispose(manager.dispose);
  return manager;
});
