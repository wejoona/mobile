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
