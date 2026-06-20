import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Wraps API payloads with encryption envelope.
///
/// This service is intentionally fail-closed until it is backed by the same
/// JWE/session-key contract used by the API interceptors. Base64 is transport
/// encoding, not encryption.
class SecurePayloadWrapper {
  static const _tag = 'PayloadWrapper';
  final AppLogger _log = AppLogger(_tag);

  /// Wrap a payload in an encrypted envelope.
  Map<String, dynamic> wrap(Map<String, dynamic> payload) {
    _log.error('Secure payload wrapping requested before implementation');
    throw UnsupportedError(
      'Secure payload wrapping is not implemented; plaintext envelope blocked.',
    );
  }

  /// Unwrap an encrypted envelope.
  Map<String, dynamic>? unwrap(Map<String, dynamic> envelope) {
    _log.error('Secure payload unwrapping requested before implementation');
    throw UnsupportedError('Secure payload unwrapping is not implemented.');
  }
}

final securePayloadWrapperProvider = Provider<SecurePayloadWrapper>((ref) {
  return SecurePayloadWrapper();
});
