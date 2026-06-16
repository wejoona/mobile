import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:usdc_wallet/services/security/network/api_request_signer.dart';
import 'package:usdc_wallet/services/security/network/response_validator.dart';

void main() {
  group('ApiRequestSigner', () {
    test('uses HMAC-SHA256 for request signatures and body hashes', () {
      const key = 'test-signing-key';
      const body = '{"amount":"10.00","currency":"USDC"}';
      const timestamp = 1780000000000;
      final signer = ApiRequestSigner(secretKey: key);
      final bodyHash = signer.computeBodyHash(body);
      final signature = signer.sign(
        method: 'POST',
        path: '/wallet/transfer',
        timestampMs: timestamp,
        bodyHash: bodyHash,
      );

      final expectedBodyHash = base64Encode(
        sha256.convert(utf8.encode(body)).bytes,
      );
      final expectedSignature = base64Encode(
        Hmac(sha256, utf8.encode(key))
            .convert(
              utf8.encode('POST\n/wallet/transfer\n$timestamp\n$bodyHash'),
            )
            .bytes,
      );

      expect(bodyHash, expectedBodyHash);
      expect(signature, expectedSignature);
      expect(signature, isNot(base64Encode(utf8.encode('POST'))));
    });

    test('fails closed when a signing key is missing', () {
      expect(
        () => ApiRequestSigner(secretKey: ''),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('verifies response signatures with the same signing key', () {
      const key = 'test-signing-key';
      const body = '{"status":"ok"}';
      const timestamp = 1780000001000;
      final signature = base64Encode(
        Hmac(
          sha256,
          utf8.encode(key),
        ).convert(utf8.encode('$body\n$timestamp')).bytes,
      );
      final signer = ApiRequestSigner(secretKey: key);

      expect(
        signer.verifyResponse(
          signature: signature,
          responseBody: body,
          timestampMs: timestamp,
        ),
        isTrue,
      );
      expect(
        signer.verifyResponse(
          signature: signature,
          responseBody: '{"status":"tampered"}',
          timestampMs: timestamp,
        ),
        isFalse,
      );
    });
  });

  group('ResponseValidator', () {
    test('validates HMAC-SHA256 response signatures', () {
      const key = 'response-key';
      const body = '{"balance":"12.34"}';
      final signature = base64Encode(
        Hmac(sha256, utf8.encode(key)).convert(utf8.encode(body)).bytes,
      );
      final validator = ResponseValidator();

      expect(validator.validateSignature(body, signature, key), isTrue);
      expect(
        validator.validateSignature('{"balance":"99.99"}', signature, key),
        isFalse,
      );
      expect(validator.validateSignature(body, signature, ''), isFalse);
    });
  });
}
