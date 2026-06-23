import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/api/cache_interceptor.dart';

void main() {
  group('CacheInterceptor', () {
    late CacheInterceptor interceptor;
    late Dio dio;

    setUp(() {
      interceptor = CacheInterceptor();
      dio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
      dio.interceptors.add(interceptor);
    });

    test('should cache GET requests', () async {
      // Mock adapter would go here in real test
      // This is a conceptual test structure
    });

    test('should return cached response for duplicate requests', () async {
      // Test cache hit scenario
    });

    test('should expire cache after TTL', () async {
      // Test TTL expiration
    });

    test('should return stale cache on network error', () async {
      // Test stale cache fallback
    });

    test('should not cache POST requests', () async {
      // Test that POST requests are not cached
    });

    test('should generate correct cache keys', () {
      final options1 = RequestOptions(
        path: '/wallet',
        method: 'GET',
        queryParameters: {'currency': 'USDC'},
      );

      final options2 = RequestOptions(
        path: '/wallet',
        method: 'GET',
        queryParameters: {'currency': 'USDT'},
      );

      // Keys should be different due to different query params
      expect(options1.uri.toString(), isNot(equals(options2.uri.toString())));
    });

    test('keeps authenticated GET caches isolated by session', () async {
      final adapter = _EchoAuthAdapter();
      dio.httpClientAdapter = adapter;

      final userOne = await dio.get<Map<String, dynamic>>(
        '/wallet/transactions',
        options: Options(headers: {'Authorization': 'Bearer user-one-token'}),
      );
      final userTwo = await dio.get<Map<String, dynamic>>(
        '/wallet/transactions',
        options: Options(headers: {'Authorization': 'Bearer user-two-token'}),
      );
      final userOneCached = await dio.get<Map<String, dynamic>>(
        '/wallet/transactions',
        options: Options(headers: {'Authorization': 'Bearer user-one-token'}),
      );

      expect(userOne.data?['owner'], 'Bearer user-one-token');
      expect(userTwo.data?['owner'], 'Bearer user-two-token');
      expect(userOneCached.data?['owner'], 'Bearer user-one-token');
      expect(adapter.calls, 2);

      final stats = interceptor.getCacheStats();
      expect(stats['total'], 2);
      expect(stats.toString(), isNot(contains('user-one-token')));
      expect(stats.toString(), isNot(contains('user-two-token')));
    });

    test('should apply correct TTL for different endpoints', () {
      // Test wallet balance TTL (fresh financial state, no generic cache)
      final walletTTL = interceptor.getTTL('/wallet');
      expect(walletTTL, equals(Duration.zero));

      // Test deposit channels TTL (30m)
      final channelsTTL = interceptor.getTTL('/deposit/channels');
      expect(channelsTTL, equals(const Duration(minutes: 30)));

      // Test exchange rate TTL (30s)
      final rateTTL = interceptor.getTTL('/rate');
      expect(rateTTL, equals(const Duration(seconds: 30)));

      // Test KYC status TTL (5m)
      final kycTTL = interceptor.getTTL('/kyc/status');
      expect(kycTTL, equals(const Duration(minutes: 5)));

      // Test default TTL (1m)
      final defaultTTL = interceptor.getTTL('/unknown/endpoint');
      expect(defaultTTL, equals(const Duration(minutes: 1)));
    });

    test('should clear all cache', () {
      interceptor.clearCache();
      final stats = interceptor.getCacheStats();
      expect(stats['total'], equals(0));
    });

    test('should clear cache for specific path', () {
      // Would need mock responses
      interceptor.clearCacheForPath('/wallet');
      // Verify wallet cache is cleared but others remain
    });

    test('should provide cache statistics', () {
      final stats = interceptor.getCacheStats();
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('total'), isTrue);
      expect(stats.containsKey('active'), isTrue);
      expect(stats.containsKey('expired'), isTrue);
      expect(stats.containsKey('entries'), isTrue);
    });
  });

  group('CachedResponse', () {
    test('should correctly identify expired cache', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        data: {'test': 'data'},
      );

      final cachedResponse = CachedResponse(
        response: response,
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );

      expect(cachedResponse.isExpired, isTrue);
    });

    test('should correctly identify valid cache', () {
      final response = Response(
        requestOptions: RequestOptions(path: '/test'),
        data: {'test': 'data'},
      );

      final cachedResponse = CachedResponse(
        response: response,
        expiresAt: DateTime.now().add(const Duration(minutes: 5)),
      );

      expect(cachedResponse.isExpired, isFalse);
    });
  });
}

class _EchoAuthAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls += 1;
    return ResponseBody.fromString(
      jsonEncode({'owner': options.headers['Authorization'], 'call': calls}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
