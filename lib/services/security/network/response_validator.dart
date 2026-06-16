import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Validates API responses for integrity and freshness.
class ResponseValidator {
  static const _tag = 'ResponseValidator';
  final AppLogger _log = AppLogger(_tag);

  /// Validate response signature.
  bool validateSignature(
    String body,
    String signature,
    String verificationKey,
  ) {
    _log.debug('Validating response signature');

    if (verificationKey.isEmpty || signature.isEmpty) {
      return false;
    }

    final expected = base64Encode(
      Hmac(
        sha256,
        utf8.encode(verificationKey),
      ).convert(utf8.encode(body)).bytes,
    );

    return _constantTimeEquals(signature, expected);
  }

  /// Check response timestamp freshness.
  bool isFresh(
    DateTime responseTime, {
    Duration maxAge = const Duration(minutes: 5),
  }) {
    return DateTime.now().difference(responseTime) < maxAge;
  }

  /// Validate required response fields.
  bool hasRequiredFields(Map<String, dynamic> body, List<String> required) {
    return required.every(body.containsKey);
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

final responseValidatorProvider = Provider<ResponseValidator>((ref) {
  return ResponseValidator();
});
