/// Cache configuration for HTTP response caching.
///
/// Define TTL (time-to-live) for different endpoints:
///
/// ```dart
/// CacheConfig.defaultTtl = Duration(seconds: 30);
/// CacheConfig.setTtl('/users', Duration(minutes: 5));
/// CacheConfig.setTtl('/config', Duration(hours: 1));
/// ```
class CacheConfig {
  CacheConfig._();

  /// Default cache TTL for endpoints without specific configuration.
  static Duration defaultTtl = const Duration(seconds: 30);

  /// TTL configuration per endpoint pattern.
  static final Map<String, Duration> _ttlConfig = {};

  /// Set TTL for a specific endpoint or pattern.
  ///
  /// [pathPattern] can be an exact path or use wildcards:
  /// - `/users` - exact match
  /// - `/users/*` - matches `/users/123`, `/users/456`
  /// - `/api/*` - matches all paths starting with `/api/`
  static void setTtl(String pathPattern, Duration ttl) {
    _ttlConfig[pathPattern] = ttl;
  }

  /// Set TTL for multiple endpoints at once.
  static void setTtls(Map<String, Duration> config) {
    _ttlConfig.addAll(config);
  }

  /// Get TTL for a specific path.
  static Duration getTtl(String path) {
    // Try exact match first
    if (_ttlConfig.containsKey(path)) {
      return _ttlConfig[path]!;
    }

    // Try wildcard patterns
    for (final entry in _ttlConfig.entries) {
      if (entry.key.endsWith('/*')) {
        final prefix = entry.key.substring(0, entry.key.length - 2);
        if (path.startsWith(prefix)) {
          return entry.value;
        }
      }
    }

    return defaultTtl;
  }

  /// Clear all TTL configurations.
  static void clearConfig() {
    _ttlConfig.clear();
  }

  /// Disable caching for a specific endpoint.
  static void disableCache(String pathPattern) {
    _ttlConfig[pathPattern] = Duration.zero;
  }

  /// Check if caching is enabled for a path.
  static bool isCacheEnabled(String path) {
    return getTtl(path) > Duration.zero;
  }

  /// Get current configuration as map.
  static Map<String, Duration> get config => Map.unmodifiable(_ttlConfig);

  /// Common presets

  /// Short-lived cache (30 seconds) - for frequently changing data
  static const shortLived = Duration(seconds: 30);

  /// Medium cache (5 minutes) - for semi-static data
  static const medium = Duration(minutes: 5);

  /// Long cache (30 minutes) - for rarely changing data
  static const long = Duration(minutes: 30);

  /// Extended cache (1 hour) - for static configuration
  static const extended = Duration(hours: 1);
}
