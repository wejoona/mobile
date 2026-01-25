import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Cached response data
class CachedResponse {
  final Response response;
  final DateTime expiresAt;

  CachedResponse({
    required this.response,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

/// HTTP Response Cache Interceptor
/// Caches GET requests to reduce network calls and improve performance
class CacheInterceptor extends Interceptor {
  final Map<String, CachedResponse> _cache = {};

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    // Only cache GET requests
    if (options.method != 'GET') {
      return handler.next(options);
    }

    final key = _generateKey(options);
    final cached = _cache[key];

    // Return cached response if not expired
    if (cached != null && !cached.isExpired) {
      if (kDebugMode) {
        debugPrint('[CacheInterceptor] Cache HIT: ${options.path}');
      }

      return handler.resolve(
        Response(
          requestOptions: options,
          data: cached.response.data,
          statusCode: cached.response.statusCode,
          statusMessage: cached.response.statusMessage,
          headers: cached.response.headers,
          extra: cached.response.extra,
        ),
        true,
      );
    }

    // Cache miss or expired
    if (kDebugMode && cached != null) {
      debugPrint('[CacheInterceptor] Cache EXPIRED: ${options.path}');
    }

    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // Only cache successful GET requests
    if (response.requestOptions.method == 'GET' &&
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300) {
      final key = _generateKey(response.requestOptions);
      final ttl = getTTL(response.requestOptions.path);

      _cache[key] = CachedResponse(
        response: response,
        expiresAt: DateTime.now().add(ttl),
      );

      if (kDebugMode) {
        debugPrint('[CacheInterceptor] Cached: ${response.requestOptions.path} (TTL: ${ttl.inSeconds}s)');
      }
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // On error, try to return stale cache if available
    if (err.requestOptions.method == 'GET') {
      final key = _generateKey(err.requestOptions);
      final cached = _cache[key];

      // Return stale cache on network errors
      if (cached != null &&
          (err.type == DioExceptionType.connectionTimeout ||
              err.type == DioExceptionType.sendTimeout ||
              err.type == DioExceptionType.receiveTimeout ||
              err.type == DioExceptionType.connectionError)) {
        if (kDebugMode) {
          debugPrint('[CacheInterceptor] Network error, returning STALE cache: ${err.requestOptions.path}');
        }

        return handler.resolve(
          Response(
            requestOptions: err.requestOptions,
            data: cached.response.data,
            statusCode: cached.response.statusCode,
            statusMessage: cached.response.statusMessage,
            headers: cached.response.headers,
            extra: cached.response.extra,
          ),
        );
      }
    }

    handler.next(err);
  }

  /// Generate cache key from request options
  String _generateKey(RequestOptions options) {
    final queryString = options.queryParameters.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');

    return '${options.method}:${options.path}${queryString.isNotEmpty ? '?$queryString' : ''}';
  }

  /// Get Time-To-Live (TTL) for different endpoints
  @visibleForTesting
  Duration getTTL(String path) {
    // Deposit channels cache for 30 minutes (rarely change)
    if (path.contains('/deposit/channels') || path.contains('/wallet/channels')) {
      return const Duration(minutes: 30);
    }

    // Exchange rates cache for 30 seconds (change frequently)
    if (path.contains('/rate') || path.contains('/exchange')) {
      return const Duration(seconds: 30);
    }

    // KYC status cache for 5 minutes
    if (path.contains('/kyc/status')) {
      return const Duration(minutes: 5);
    }

    // Referral code cache for 1 hour (rarely changes)
    if (path.contains('/referrals/code')) {
      return const Duration(hours: 1);
    }

    // Referral stats/history cache for 5 minutes
    if (path.contains('/referrals')) {
      return const Duration(minutes: 5);
    }

    // Wallet balance cache for 30 seconds
    if (path.contains('/wallet/balance')) {
      return const Duration(seconds: 30);
    }

    // Transaction list cache for 1 minute
    if (path.contains('/transactions')) {
      return const Duration(minutes: 1);
    }

    // Default cache: 1 minute
    return const Duration(minutes: 1);
  }

  /// Clear all cached responses
  void clearCache() {
    _cache.clear();
    if (kDebugMode) {
      debugPrint('[CacheInterceptor] Cache cleared');
    }
  }

  /// Clear specific cached endpoint
  void clearCacheForPath(String path) {
    _cache.removeWhere((key, value) => key.contains(path));
    if (kDebugMode) {
      debugPrint('[CacheInterceptor] Cache cleared for: $path');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final now = DateTime.now();
    final activeEntries = _cache.values.where((c) => !c.isExpired).length;
    final expiredEntries = _cache.values.where((c) => c.isExpired).length;

    return {
      'total': _cache.length,
      'active': activeEntries,
      'expired': expiredEntries,
      'entries': _cache.entries.map((e) => {
        'key': e.key,
        'isExpired': e.value.isExpired,
        'expiresIn': e.value.expiresAt.difference(now).inSeconds,
      }).toList(),
    };
  }
}
