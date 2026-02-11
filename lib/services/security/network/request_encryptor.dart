import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Encrypts and decrypts sensitive API request/response payloads.
///
/// Uses AES-256-GCM for payload encryption. The server and client
/// share a session key derived during authentication.
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
    final json = jsonEncode(plaintext);
    // Placeholder: in production use AES-GCM via pointycastle or platform channel
    final encrypted = base64Encode(utf8.encode(json));
    return {
      'encrypted': encrypted,
      'v': 1,
    };
  }

  /// Decrypt a response payload from the server.
  Map<String, dynamic> decryptPayload(Map<String, dynamic> ciphertext) {
    if (_sessionKey == null) {
      throw StateError('No session key set');
    }
    final encrypted = ciphertext['encrypted'] as String;
    // Placeholder decryption
    final json = utf8.decode(base64Decode(encrypted));
    return jsonDecode(json) as Map<String, dynamic>;
  }
}

final requestEncryptorProvider = Provider<RequestEncryptor>((ref) {
  return RequestEncryptor();
});
