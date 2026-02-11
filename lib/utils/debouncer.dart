import 'dart:async';

/// Utility to debounce function calls.
class Debouncer {
  final Duration duration;
  Timer? _timer;

  Debouncer({this.duration = const Duration(milliseconds: 300)});

  /// Run [action] after the debounce period.
  void run(void Function() action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  /// Cancel any pending debounced action.
  void cancel() {
    _timer?.cancel();
    _timer = null;
  }

  /// Whether there is a pending action.
  bool get isPending => _timer?.isActive ?? false;

  /// Dispose the debouncer.
  void dispose() {
    cancel();
  }
}
