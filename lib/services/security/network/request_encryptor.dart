import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Legacy request encryption boundary.
///
/// Active sensitive API encryption uses the JWE interceptor. This class stays
/// fail-closed so older imports cannot accidentally ship reversible encoding as
/// encryption.
class RequestEncryptor {
  static const _tag = 'RequestEncryptor';
  final AppLogger _log = AppLogger(_tag);

  Uint8List? _sessionKey;

  /// Set the session encryption key (derived after auth).
  void setSessionKey(Uint8List key) {
    if (key.length != 32) {
      throw ArgumentError('Session key must be 256 bits');
    }
    _sessionKey = key;
    _log.debug('Session encryption key set');
  }

  /// Clear the session key (on logout).
  void clearSessionKey() {
    _sessionKey = null;
    _log.debug('Session encryption key cleared');
  }

  bool get hasSessionKey => _sessionKey != null;

  /// Encrypt a JSON payload for transmission.
  Map<String, dynamic> encryptPayload(Map<String, dynamic> plaintext) {
    if (_sessionKey == null) {
      throw StateError('No session key set');
    }
    _log.error('Legacy request encryption requested before implementation');
    throw UnsupportedError(
      'Legacy request encryption is not implemented; use JWE for sensitive API payloads.',
    );
  }

  /// Decrypt a response payload from the server.
  Map<String, dynamic> decryptPayload(Map<String, dynamic> ciphertext) {
    if (_sessionKey == null) {
      throw StateError('No session key set');
    }
    throw UnsupportedError(
      'Legacy response decryption is not implemented; use JWE for sensitive API payloads.',
    );
  }
}

final requestEncryptorProvider = Provider<RequestEncryptor>((ref) {
  return RequestEncryptor();
});
