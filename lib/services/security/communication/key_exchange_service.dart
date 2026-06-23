import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Manages Diffie-Hellman style key exchange for E2E encryption.
///
/// This boundary is intentionally fail-closed until real X25519 or another
/// reviewed key agreement implementation is wired end-to-end.
class KeyExchangeService {
  static const _tag = 'KeyExchange';
  final AppLogger _log = AppLogger(_tag);

  /// Generate a key pair for exchange.
  KeyPair generateKeyPair() {
    _log.error('Key exchange requested before implementation');
    throw UnsupportedError(
      'Key exchange is not implemented; key generation blocked.',
    );
  }

  /// Derive shared secret from own private key and peer's public key.
  String deriveSharedSecret(String privateKey, String peerPublicKey) {
    _log.error('Shared-secret derivation requested before implementation');
    throw UnsupportedError(
      'Key exchange is not implemented; shared-secret derivation blocked.',
    );
  }
}

class KeyPair {
  final String publicKey;
  final String privateKey;
  const KeyPair({required this.publicKey, required this.privateKey});
}

final keyExchangeServiceProvider = Provider<KeyExchangeService>((ref) {
  return KeyExchangeService();
});
