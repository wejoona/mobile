import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Signs API requests with HMAC-SHA256 to ensure integrity.
///
/// The signature is computed over the canonical request string
/// (method + path + timestamp + body hash) and sent as X-Request-Signature.
class ApiRequestSigner {
  static const _tag = 'ApiRequestSigner';
  final AppLogger _log = AppLogger(_tag);

  final String _secretKey;

  ApiRequestSigner({required String secretKey}) : _secretKey = secretKey {
    if (secretKey.isEmpty) {
      throw ArgumentError.value(
        secretKey,
        'secretKey',
        'Request signing requires a non-empty key.',
      );
    }
  }

  /// Generate signature for the given request components.
  String sign({
    required String method,
    required String path,
    required int timestampMs,
    String? bodyHash,
  }) {
    final canonical = '$method\n$path\n$timestampMs\n${bodyHash ?? ''}';
    final signature = base64Encode(
      Hmac(
        sha256,
        utf8.encode(_secretKey),
      ).convert(utf8.encode(canonical)).bytes,
    );
    _log.debug('Signed request: $method $path');
    return signature;
  }

  /// Compute body hash (SHA-256 of request body).
  String computeBodyHash(String body) {
    return base64Encode(sha256.convert(utf8.encode(body)).bytes);
  }

  /// Verify a response signature from the server.
  bool verifyResponse({
    required String signature,
    required String responseBody,
    required int timestampMs,
  }) {
    try {
      final expected = base64Encode(
        Hmac(
          sha256,
          utf8.encode(_secretKey),
        ).convert(utf8.encode('$responseBody\n$timestampMs')).bytes,
      );
      return _constantTimeEquals(signature, expected);
    } catch (e) {
      _log.error('Response signature verification failed', e);
      return false;
    }
  }

  bool _constantTimeEquals(String left, String right) {
    final leftBytes = utf8.encode(left);
    final rightBytes = utf8.encode(right);

    if (leftBytes.length != rightBytes.length) {
      return false;
    }

    var diff = 0;
    for (var i = 0; i < leftBytes.length; i++) {
      diff |= leftBytes[i] ^ rightBytes[i];
    }
    return diff == 0;
  }
}

final apiRequestSignerProvider = Provider<ApiRequestSigner>((ref) {
  const secretKey = String.fromEnvironment('API_REQUEST_SIGNING_KEY');
  return ApiRequestSigner(secretKey: secretKey);
});
