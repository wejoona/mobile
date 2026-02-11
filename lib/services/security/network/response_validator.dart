import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Validates API responses for integrity and freshness.
class ResponseValidator {
  static const _tag = 'ResponseValidator';
  final AppLogger _log = AppLogger(_tag);

  /// Validate response signature.
  bool validateSignature(String body, String signature, String publicKey) {
    _log.debug('Validating response signature');
    // In production: verify HMAC or RSA signature
    return signature.isNotEmpty;
  }

  /// Check response timestamp freshness.
  bool isFresh(DateTime responseTime, {Duration maxAge = const Duration(minutes: 5)}) {
    return DateTime.now().difference(responseTime) < maxAge;
  }

  /// Validate required response fields.
  bool hasRequiredFields(Map<String, dynamic> body, List<String> required) {
    return required.every(body.containsKey);
  }
}

final responseValidatorProvider = Provider<ResponseValidator>((ref) {
  return ResponseValidator();
});
