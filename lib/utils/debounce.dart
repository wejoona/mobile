import 'dart:async';

/// A simple debouncer that delays execution until [duration] has passed
/// since the last call.
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Run [action] after [duration] has elapsed since the last call.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending execution.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether a call is currently pending.
  bool get isPending => _timer?.isActive ?? false;

  /// Dispose the debouncer.
  void dispose() {
    cancel();
  }
}

/// A throttler that ensures [action] runs at most once per [duration].
class Throttler {
  final Duration duration;
  DateTime? _lastRun;

  Throttler({this.duration = const Duration(milliseconds: 500)});

  /// Run [action] only if [duration] has passed since the last execution.
  void run(void Function() action) {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= duration) {
      _lastRun = now;
      action();
    }
  }

  /// Reset the throttler so the next call will execute immediately.
  void reset() {
    _lastRun = null;
  }
}
