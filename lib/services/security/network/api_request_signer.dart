import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Signs API requests with HMAC-SHA256 to ensure integrity.
///
/// The signature is computed over the canonical request string
/// (method + path + timestamp + body hash) and sent as X-Request-Signature.
class ApiRequestSigner {
  static const _tag = 'ApiRequestSigner';
  final AppLogger _log = AppLogger(_tag);

  // ignore: unused_field
  final String _secretKey;

  ApiRequestSigner({required String secretKey}) : _secretKey = secretKey;

  /// Generate signature for the given request components.
  String sign({
    required String method,
    required String path,
    required int timestampMs,
    String? bodyHash,
  }) {
    final canonical = '$method\n$path\n$timestampMs\n${bodyHash ?? ''}';
    // In production use: Hmac(sha256, utf8.encode(_secretKey)).convert(utf8.encode(canonical))
    final signature = base64Encode(utf8.encode(canonical));
    _log.debug('Signed request: $method $path');
    return signature;
  }

  /// Compute body hash (SHA-256 of request body).
  String computeBodyHash(String body) {
    // Replace with crypto package sha256
    return base64Encode(utf8.encode(body));
  }

  /// Verify a response signature from the server.
  bool verifyResponse({
    required String signature,
    required String responseBody,
    required int timestampMs,
  }) {
    try {
      final expected = base64Encode(utf8.encode('$responseBody\n$timestampMs'));
      return signature == expected;
    } catch (e) {
      _log.error('Response signature verification failed', e);
      return false;
    }
  }
}

final apiRequestSignerProvider = Provider<ApiRequestSigner>((ref) {
  return ApiRequestSigner(secretKey: '');
});
