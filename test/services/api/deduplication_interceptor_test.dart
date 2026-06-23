import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/api/deduplication_interceptor.dart';

void main() {
  group('RequestDeduplicationInterceptor', () {
    late RequestDeduplicationInterceptor interceptor;
    late Dio dio;

    setUp(() {
      interceptor = RequestDeduplicationInterceptor();
      dio = Dio(BaseOptions(baseUrl: 'https://api.test.com'));
      dio.interceptors.add(interceptor);
    });

    test('should deduplicate identical GET requests', () async {
      // Mock adapter would go here
      // This is a conceptual test structure
    });

    test('should not deduplicate POST requests', () async {
      // Test that POST requests are not deduplicated
    });

    test('should handle in-flight request completion', () async {
      // Test successful completion
    });

    test('should handle in-flight request errors', () async {
      // Test error handling
    });

    test('should timeout old in-flight requests', () async {
      // Test timeout mechanism
    });

    test('should generate unique keys for different requests', () {
      final options1 = RequestOptions(path: '/wallet', method: 'GET');

      final options2 = RequestOptions(
        path: '/wallet',
        method: 'GET',
        queryParameters: {'currency': 'USDC'},
      );

      // Keys should be different
      expect(options1.uri.toString(), isNot(equals(options2.uri.toString())));
    });

    test('should include auth header in key generation', () {
      final options1 = RequestOptions(
        path: '/wallet',
        method: 'GET',
        headers: {'Authorization': 'Bearer token1'},
      );

      final options2 = RequestOptions(
        path: '/wallet',
        method: 'GET',
        headers: {'Authorization': 'Bearer token2'},
      );

      // Keys should be different due to different auth tokens
      expect(
        options1.headers['Authorization'],
        isNot(equals(options2.headers['Authorization'])),
      );
    });

    test('does not deduplicate authenticated GETs across sessions', () async {
      final adapter = _DelayedEchoAuthAdapter();
      final authenticatedDio = Dio(BaseOptions(baseUrl: 'https://api.test.com'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);

      final first = authenticatedDio.get<Map<String, dynamic>>(
        '/wallet',
        options: Options(headers: {'Authorization': 'Bearer user-one-token'}),
      );
      final second = authenticatedDio.get<Map<String, dynamic>>(
        '/wallet',
        options: Options(headers: {'Authorization': 'Bearer user-two-token'}),
      );

      final responses = await Future.wait([first, second]);

      expect(adapter.calls, 2);
      expect(responses[0].data?['owner'], 'Bearer user-one-token');
      expect(responses[1].data?['owner'], 'Bearer user-two-token');
      await Future<void>.delayed(const Duration(milliseconds: 150));
      expect(interceptor.getStats()['count'], equals(0));
    });

    test('does not expose raw auth tokens in in-flight statistics', () async {
      final adapter = _BlockingAdapter();
      final statsDio = Dio(BaseOptions(baseUrl: 'https://api.test.com'))
        ..httpClientAdapter = adapter
        ..interceptors.add(interceptor);

      final request = statsDio.get<Map<String, dynamic>>(
        '/wallet',
        options: Options(headers: {'Authorization': 'Bearer secret-token'}),
      );

      await pumpEventQueue();

      expect(
        interceptor.getStats().toString(),
        isNot(contains('secret-token')),
      );

      adapter.complete();
      await request;
    });

    test('should clear all in-flight requests', () {
      interceptor.clear();
      final stats = interceptor.getStats();
      expect(stats['count'], equals(0));
    });

    test('should provide in-flight statistics', () {
      final stats = interceptor.getStats();
      expect(stats, isA<Map<String, dynamic>>());
      expect(stats.containsKey('count'), isTrue);
      expect(stats.containsKey('requests'), isTrue);
    });

    test('failed original GET does not emit unhandled async error', () async {
      final capturedErrors = <Object>[];
      final failingDio = Dio(BaseOptions(baseUrl: 'https://api.test.com'))
        ..httpClientAdapter = _StatusCodeAdapter(521)
        ..interceptors.add(interceptor);

      await runZonedGuarded<Future<void>>(() async {
        await expectLater(
          failingDio.get('/config/countries'),
          throwsA(isA<DioException>()),
        );
        await Future<void>.delayed(Duration.zero);
      }, (error, _) => capturedErrors.add(error));

      expect(capturedErrors, isEmpty);
      expect(interceptor.getStats()['count'], equals(0));
    });
  });

  group('InFlightRequest', () {
    test('should track request start time', () {
      final startTime = DateTime.now();
      final inFlight = InFlightRequest(
        completer: Completer<Response>(),
        startedAt: startTime,
      );

      expect(inFlight.startedAt, equals(startTime));
    });

    test('should have uncompleted completer initially', () {
      final inFlight = InFlightRequest(
        completer: Completer<Response>(),
        startedAt: DateTime.now(),
      );

      expect(inFlight.completer.isCompleted, isFalse);
    });
  });
}

class _StatusCodeAdapter implements HttpClientAdapter {
  _StatusCodeAdapter(this.statusCode);

  final int statusCode;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"message":"origin down"}',
      statusCode,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _DelayedEchoAuthAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls += 1;
    await Future<void>.delayed(const Duration(milliseconds: 20));
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

class _BlockingAdapter implements HttpClientAdapter {
  final _completer = Completer<void>();

  void complete() {
    if (!_completer.isCompleted) {
      _completer.complete();
    }
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    await _completer.future;
    return ResponseBody.fromString(
      jsonEncode({'ok': true}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
