import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/providers/missing_providers.dart';
import 'package:usdc_wallet/services/api/api_client.dart';

void main() {
  test('ignores in-flight refresh results after auto-dispose', () async {
    final adapter = _DelayedTransactionsAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'))
      ..httpClientAdapter = adapter;
    final errors = <Object>[];

    await runZonedGuarded(() async {
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );

      container..read(filteredPaginatedTransactionsProvider);
      await adapter.waitForFetch();

      container.dispose();
      adapter.complete();
      await Future<void>.delayed(Duration.zero);
    }, (error, _) => errors.add(error));

    expect(errors, isEmpty);
  });

  test(
    'keeps loaded transaction history visible after refresh failure',
    () async {
      final adapter = _SequencedTransactionsAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://api.korido.test/api/v1'))
        ..httpClientAdapter = adapter;
      final container = ProviderContainer(
        overrides: [dioProvider.overrideWithValue(dio)],
      );
      addTearDown(container.dispose);
      final subscription = container.listen(
        filteredPaginatedTransactionsProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);

      await adapter.waitForFetch(1);
      await _pumpUntil(
        () => container
            .read(filteredPaginatedTransactionsProvider)
            .transactions
            .isNotEmpty,
      );

      final loadedState = container.read(filteredPaginatedTransactionsProvider);
      expect(loadedState.transactions, hasLength(1));
      expect(loadedState.error, isNull);

      await container
          .read(filteredPaginatedTransactionsProvider.notifier)
          .refresh();

      final failedRefreshState = container.read(
        filteredPaginatedTransactionsProvider,
      );
      expect(failedRefreshState.transactions, hasLength(1));
      expect(failedRefreshState.error, isNotNull);
      expect(failedRefreshState.isLoading, isFalse);
    },
  );
}

Future<void> _pumpUntil(
  bool Function() condition, {
  Duration timeout = const Duration(seconds: 2),
}) async {
  final deadline = DateTime.now().add(timeout);
  while (!condition()) {
    if (DateTime.now().isAfter(deadline)) {
      throw TimeoutException('Condition was not met before timeout');
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}

class _DelayedTransactionsAdapter implements HttpClientAdapter {
  final Completer<void> _fetchStarted = Completer<void>();
  final Completer<void> _completeResponse = Completer<void>();

  Future<void> waitForFetch() => _fetchStarted.future;

  void complete() {
    if (!_completeResponse.isCompleted) {
      _completeResponse.complete();
    }
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (!_fetchStarted.isCompleted) {
      _fetchStarted.complete();
    }
    await _completeResponse.future;
    return ResponseBody.fromString(
      '{"transactions":[],"hasMore":false}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _SequencedTransactionsAdapter implements HttpClientAdapter {
  var _requestCount = 0;
  final _requestCompleters = <int, Completer<void>>{};

  Future<void> waitForFetch(int requestNumber) {
    return _requestCompleters
        .putIfAbsent(requestNumber, Completer<void>.new)
        .future;
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requestCount += 1;
    _requestCompleters
        .putIfAbsent(_requestCount, Completer<void>.new)
        .complete();

    if (_requestCount == 1) {
      return ResponseBody.fromString(
        '''
{
  "transactions": [
    {
      "id": "tx_1",
      "walletId": "wallet_1",
      "type": "deposit",
      "status": "completed",
      "amount": "42.50",
      "currency": "USDC",
      "createdAt": "2026-06-16T00:00:00Z"
    }
  ],
  "total": 2,
  "hasMore": true
}
''',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    return ResponseBody.fromString(
      '{"message":"transaction history temporarily unavailable"}',
      503,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
