/// List extension methods used across the app.
extension ListExtensions<T> on List<T> {
  /// Group items by a key function.
  Map<K, List<T>> groupBy<K>(K Function(T) keyFn) {
    final map = <K, List<T>>{};
    for (final item in this) {
      final key = keyFn(item);
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Return a list with duplicates removed based on [keyFn].
  List<T> uniqueBy<K>(K Function(T) keyFn) {
    final seen = <K>{};
    return where((item) => seen.add(keyFn(item))).toList();
  }

  /// Safe element access — returns null if index is out of bounds.
  T? getOrNull(int index) =>
      index >= 0 && index < length ? this[index] : null;

  /// Split list into chunks of [size].
  List<List<T>> chunked(int size) {
    final chunks = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      chunks.add(sublist(i, (i + size).clamp(0, length)));
    }
    return chunks;
  }

  /// Return a sorted copy (does not mutate original).
  List<T> sortedBy<K extends Comparable>(K Function(T) keyFn) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keyFn(a).compareTo(keyFn(b)));
    return copy;
  }

  /// Return a reversed sorted copy.
  List<T> sortedByDescending<K extends Comparable>(K Function(T) keyFn) {
    final copy = List<T>.from(this);
    copy.sort((a, b) => keyFn(b).compareTo(keyFn(a)));
    return copy;
  }

  /// Sum numeric values.
  double sumBy(num Function(T) selector) {
    var total = 0.0;
    for (final item in this) {
      total += selector(item);
    }
    return total;
  }
}

/// Iterable extensions.
extension IterableExtensions<T> on Iterable<T> {
  /// First element matching predicate, or null.
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
