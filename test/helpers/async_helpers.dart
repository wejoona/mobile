import 'dart:async';

/// Create a completer that resolves with a value after a delay.
Future<T> delayedValue<T>(T value, {Duration? delay}) async {
  await Future.delayed(delay ?? const Duration(milliseconds: 10));
  return value;
}

/// Create a completer that throws after a delay.
Future<T> delayedError<T>(Object error, {Duration? delay}) async {
  await Future.delayed(delay ?? const Duration(milliseconds: 10));
  throw error;
}

/// Fake stream controller for testing stream-based providers.
class FakeStreamController<T> {
  final _controller = StreamController<T>.broadcast();

  Stream<T> get stream => _controller.stream;

  void add(T value) => _controller.add(value);
  void addError(Object error) => _controller.addError(error);
  Future<void> close() => _controller.close();
}
