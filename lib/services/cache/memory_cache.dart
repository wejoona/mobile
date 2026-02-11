/// Simple in-memory TTL cache for API responses.
class MemoryCache {
  final Map<String, _CacheEntry> _store = {};
  final Duration defaultTtl;

  MemoryCache({this.defaultTtl = const Duration(minutes: 5)});

  /// Get a cached value, or null if expired/missing.
  T? get<T>(String key) {
    final entry = _store[key];
    if (entry == null) return null;
    if (entry.isExpired) {
      _store.remove(key);
      return null;
    }
    return entry.value as T;
  }

  /// Put a value in the cache.
  void put<T>(String key, T value, {Duration? ttl}) {
    _store[key] = _CacheEntry(
      value: value,
      expiresAt: DateTime.now().add(ttl ?? defaultTtl),
    );
  }

  /// Get or compute: returns cached value or calls [compute] and caches result.
  Future<T> getOrCompute<T>(
    String key,
    Future<T> Function() compute, {
    Duration? ttl,
  }) async {
    final cached = get<T>(key);
    if (cached != null) return cached;

    final value = await compute();
    put(key, value, ttl: ttl);
    return value;
  }

  /// Remove a specific key.
  void remove(String key) => _store.remove(key);

  /// Clear all cached values.
  void clear() => _store.clear();

  /// Remove all expired entries.
  void evictExpired() {
    _store.removeWhere((_, entry) => entry.isExpired);
  }

  /// Number of cached entries.
  int get size => _store.length;

  /// All cached keys.
  Iterable<String> get keys => _store.keys;
}

class _CacheEntry {
  final dynamic value;
  final DateTime expiresAt;

  _CacheEntry({required this.value, required this.expiresAt});

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
