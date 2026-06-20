import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/security/communication/e2e_encryption_service.dart';
import 'package:usdc_wallet/services/security/communication/message_encryptor.dart';
import 'package:usdc_wallet/services/security/network/encrypted_request_interceptor.dart';
import 'package:usdc_wallet/services/security/network/request_encryptor.dart';

void main() {
  group('legacy crypto boundaries', () {
    test('do not expose reversible encodings as encryption', () async {
      expect(
        () => MessageEncryptor().encrypt('secret', 'recipient-key'),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => MessageEncryptor().decrypt('c2VjcmV0', 'private-key'),
        throwsA(isA<UnsupportedError>()),
      );

      final e2e = E2eEncryptionService();
      expect(e2e.generateKeyPair(), throwsA(isA<UnsupportedError>()));
      expect(
        () => e2e.deriveSharedSecret(Uint8List(32)),
        throwsA(isA<UnsupportedError>()),
      );
      expect(() => e2e.encrypt('secret'), throwsA(isA<UnsupportedError>()));
      expect(() => e2e.decrypt('c2VjcmV0'), throwsA(isA<UnsupportedError>()));

      final requestEncryptor = RequestEncryptor()..setSessionKey(Uint8List(32));
      expect(
        () => requestEncryptor.encryptPayload({'pin': '123456'}),
        throwsA(isA<UnsupportedError>()),
      );
      expect(
        () => requestEncryptor.decryptPayload({'encrypted': 'e30='}),
        throwsA(isA<UnsupportedError>()),
      );
    });

    test(
      'legacy encrypted interceptor blocks sensitive plaintext fallback',
      () async {
        final adapter = _RecordingAdapter();
        final encryptor = RequestEncryptor()..setSessionKey(Uint8List(32));
        final dio = Dio(BaseOptions(baseUrl: 'https://korido.test'))
          ..httpClientAdapter = adapter
          ..interceptors.add(EncryptedRequestInterceptor(encryptor: encryptor));

        await expectLater(
          dio.post(ApiEndpoints.userPinChange, data: {'pin': '123456'}),
          throwsA(
            isA<DioException>().having(
              (error) => error.message,
              'message',
              contains('plaintext transmission blocked'),
            ),
          ),
        );

        expect(adapter.seenRequests, isEmpty);
      },
    );
  });
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
    return ResponseBody.fromString('{"ok":true}', 200);
  }

  @override
  void close({bool force = false}) {}
}
