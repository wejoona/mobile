import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';

/// Performance utilities for cache and request management
class PerformanceUtils {
  final Ref _ref;

  PerformanceUtils(this._ref);

  /// Clear all HTTP caches
  void clearAllCaches() {
    final cacheInterceptor = _ref.read(cacheInterceptorProvider);
    cacheInterceptor.clearCache();
  }

  /// Clear cache for specific path
  void clearCacheForPath(String path) {
    final cacheInterceptor = _ref.read(cacheInterceptorProvider);
    cacheInterceptor.clearCacheForPath(path);
  }

  /// Clear cache for wallet-related endpoints
  void clearWalletCache() {
    clearCacheForPath('/wallet');
  }

  /// Clear cache for transaction-related endpoints
  void clearTransactionCache() {
    clearCacheForPath('/transactions');
  }

  /// Clear cache for referral-related endpoints
  void clearReferralCache() {
    clearCacheForPath('/referrals');
  }

  /// Clear all in-flight requests
  void clearInFlightRequests() {
    final deduplicationInterceptor = _ref.read(deduplicationInterceptorProvider);
    deduplicationInterceptor.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    final cacheInterceptor = _ref.read(cacheInterceptorProvider);
    return cacheInterceptor.getCacheStats();
  }

  /// Get in-flight request statistics
  Map<String, dynamic> getInFlightStats() {
    final deduplicationInterceptor = _ref.read(deduplicationInterceptorProvider);
    return deduplicationInterceptor.getStats();
  }

  /// Get all performance statistics
  Map<String, dynamic> getAllStats() {
    return {
      'cache': getCacheStats(),
      'inFlight': getInFlightStats(),
    };
  }
}

/// Performance Utils Provider
final performanceUtilsProvider = Provider<PerformanceUtils>((ref) {
  return PerformanceUtils(ref);
});
