import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio_performance_kit/src/cache_config.dart';

/// Cached response entry.
class _CacheEntry {
  final Response response;
  final DateTime expiresAt;

  _CacheEntry(this.response, this.expiresAt);

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// HTTP response caching interceptor for Dio.
///
/// Caches successful GET responses and returns cached data when available.
///
/// ## Features
/// - Configurable TTL per endpoint
/// - Automatic cache expiration
/// - Cache statistics
/// - Manual cache clearing
///
/// ## Usage
///
/// ```dart
/// final cacheInterceptor = CacheInterceptor();
///
/// // Configure TTLs
/// CacheConfig.setTtl('/users', Duration(minutes: 5));
/// CacheConfig.setTtl('/config', Duration(hours: 1));
///
/// // Add to Dio
/// dio.interceptors.add(cacheInterceptor);
///
/// // Clear cache when needed
/// cacheInterceptor.clearCache();
/// cacheInterceptor.clearCacheForPath('/users');
/// ```
class CacheInterceptor extends Interceptor {
  /// In-memory cache storage.
  final Map<String, _CacheEntry> _cache = {};

  /// Cache hit counter.
  int _hits = 0;

  /// Cache miss counter.
  int _misses = 0;

  /// Whether to log cache activity (debug mode only).
  final bool enableLogging;

  /// Only cache GET requests.
  final bool cacheGetOnly;

  CacheInterceptor({
    this.enableLogging = true,
    this.cacheGetOnly = true,
  });

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Only cache GET requests (unless configured otherwise)
    if (cacheGetOnly && options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }

    final cacheKey = _generateCacheKey(options);
    final entry = _cache[cacheKey];

    if (entry != null && !entry.isExpired) {
      _hits++;
      _log('CACHE HIT: ${options.path}');

      // Return cached response
      handler.resolve(
        Response(
          requestOptions: options,
          statusCode: entry.response.statusCode,
          data: entry.response.data,
          headers: entry.response.headers,
        ),
        true, // Call resolve with true to prevent other interceptors
      );
      return;
    }

    // Cache miss or expired
    if (entry != null && entry.isExpired) {
      _cache.remove(cacheKey);
      _log('CACHE EXPIRED: ${options.path}');
    }

    _misses++;
    _log('CACHE MISS: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    final options = response.requestOptions;

    // Only cache successful GET responses
    if (cacheGetOnly && options.method.toUpperCase() != 'GET') {
      handler.next(response);
      return;
    }

    // Only cache successful responses (2xx)
    if (response.statusCode == null ||
        response.statusCode! < 200 ||
        response.statusCode! >= 300) {
      handler.next(response);
      return;
    }

    // Check if caching is enabled for this path
    final ttl = CacheConfig.getTtl(options.path);
    if (ttl == Duration.zero) {
      handler.next(response);
      return;
    }

    // Store in cache
    final cacheKey = _generateCacheKey(options);
    _cache[cacheKey] = _CacheEntry(
      response,
      DateTime.now().add(ttl),
    );

    _log('CACHED: ${options.path} (TTL: ${ttl.inSeconds}s)');
    handler.next(response);
  }

  /// Generate cache key from request options.
  String _generateCacheKey(RequestOptions options) {
    final buffer = StringBuffer();
    buffer.write(options.method);
    buffer.write(':');
    buffer.write(options.path);

    // Include query parameters in cache key
    if (options.queryParameters.isNotEmpty) {
      final sortedParams = options.queryParameters.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      buffer.write('?');
      buffer.write(sortedParams.map((e) => '${e.key}=${e.value}').join('&'));
    }

    return buffer.toString();
  }

  void _log(String message) {
    if (enableLogging && kDebugMode) {
      debugPrint('[CacheInterceptor] $message');
    }
  }

  // ============================================
  // CACHE MANAGEMENT
  // ============================================

  /// Clear all cached responses.
  void clearCache() {
    _cache.clear();
    _log('Cache cleared');
  }

  /// Clear cache for a specific path.
  ///
  /// [path] - Exact path or pattern with wildcard (e.g., '/users/*')
  void clearCacheForPath(String path) {
    if (path.endsWith('/*')) {
      final prefix = path.substring(0, path.length - 2);
      _cache.removeWhere((key, _) => key.contains(prefix));
    } else {
      _cache.removeWhere((key, _) => key.contains(path));
    }
    _log('Cache cleared for: $path');
  }

  /// Clear expired cache entries.
  void clearExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
    _log('Expired entries cleared');
  }

  /// Get cache statistics.
  CacheStats get stats => CacheStats(
        hits: _hits,
        misses: _misses,
        entries: _cache.length,
        expiredEntries: _cache.values.where((e) => e.isExpired).length,
      );

  /// Reset statistics.
  void resetStats() {
    _hits = 0;
    _misses = 0;
  }

  /// Get all cached paths (for debugging).
  List<String> get cachedPaths => _cache.keys.toList();
}

/// Cache statistics.
class CacheStats {
  final int hits;
  final int misses;
  final int entries;
  final int expiredEntries;

  const CacheStats({
    required this.hits,
    required this.misses,
    required this.entries,
    required this.expiredEntries,
  });

  /// Total requests (hits + misses).
  int get total => hits + misses;

  /// Cache hit rate (0.0 to 1.0).
  double get hitRate => total > 0 ? hits / total : 0.0;

  /// Cache hit rate as percentage string.
  String get hitRatePercent => '${(hitRate * 100).toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'CacheStats(hits: $hits, misses: $misses, hitRate: $hitRatePercent, entries: $entries)';
  }

  Map<String, dynamic> toJson() => {
        'hits': hits,
        'misses': misses,
        'total': total,
        'hitRate': hitRate,
        'entries': entries,
        'expiredEntries': expiredEntries,
      };
}
