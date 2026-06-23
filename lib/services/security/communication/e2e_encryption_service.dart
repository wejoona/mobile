import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// End-to-end encryption for sensitive payloads.
///
/// This boundary is intentionally fail-closed until a real X25519/AES-GCM
/// implementation or platform-backed crypto channel is wired end-to-end.
class E2eEncryptionService {
  static const _tag = 'E2eEncryption';
  final AppLogger _log = AppLogger(_tag);

  /// Generate ephemeral key pair for this session.
  Future<Uint8List> generateKeyPair() async {
    _log.error('E2E key generation requested before crypto implementation');
    throw UnsupportedError(
      'E2E encryption is not implemented; key generation blocked.',
    );
  }

  /// Derive shared secret from server's public key.
  void deriveSharedSecret(Uint8List serverPublicKey) {
    _log.error('E2E shared-secret derivation requested before implementation');
    throw UnsupportedError(
      'E2E encryption is not implemented; shared-secret derivation blocked.',
    );
  }

  /// Encrypt sensitive payload.
  String encrypt(String plaintext) {
    _log.error('E2E encryption requested before implementation');
    throw UnsupportedError(
      'E2E encryption is not implemented; plaintext transmission blocked.',
    );
  }

  /// Decrypt received payload.
  String decrypt(String ciphertext) {
    throw UnsupportedError('E2E decryption is not implemented.');
  }

  /// Clear all key material.
  void dispose() {
    _log.debug('Key material cleared');
  }
}

final e2eEncryptionServiceProvider = Provider<E2eEncryptionService>((ref) {
  final service = E2eEncryptionService();
  ref.onDispose(service.dispose);
  return service;
});
