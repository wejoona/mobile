import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/security/jwe/jwe_interceptor.dart';
import 'package:usdc_wallet/services/security/jwe/jwe_service.dart';

void main() {
  group('JweInterceptor', () {
    test('fails closed instead of sending sensitive plaintext', () async {
      final adapter = _RecordingAdapter();
      final dio = Dio(BaseOptions(baseUrl: 'https://korido.test'))
        ..httpClientAdapter = adapter
        ..interceptors.add(JweInterceptor(_FailingJweService()));

      await expectLater(
        dio.post(ApiEndpoints.userPinSet, data: {'pin': '123456'}),
        throwsA(
          isA<DioException>().having(
            (error) => error.message,
            'message',
            contains('plaintext transmission blocked'),
          ),
        ),
      );

      expect(
        adapter.seenRequests,
        isEmpty,
        reason:
            'PIN and money payloads must not reach the network when JWE encryption fails.',
      );
    });

    test(
      'allows non-sensitive requests when encryption service is unavailable',
      () async {
        final adapter = _RecordingAdapter();
        final dio = Dio(BaseOptions(baseUrl: 'https://korido.test'))
          ..httpClientAdapter = adapter
          ..interceptors.add(JweInterceptor(_FailingJweService()));

        final response = await dio.get('/config/countries');

        expect(response.statusCode, 200);
        expect(adapter.seenRequests.single.path, '/config/countries');
      },
    );
  });
}

class _FailingJweService extends JweService {
  @override
  Future<String> encrypt(Map<String, dynamic> payload) async {
    throw StateError('server key unavailable');
  }
}

class _RecordingAdapter implements HttpClientAdapter {
  final seenRequests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    seenRequests.add(options);
    return ResponseBody.fromString(
      '{"ok":true}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
