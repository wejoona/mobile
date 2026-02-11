import 'dart:convert';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Manages Diffie-Hellman style key exchange for E2E encryption.
class KeyExchangeService {
  static const _tag = 'KeyExchange';
  final AppLogger _log = AppLogger(_tag);
  final Random _random = Random.secure();

  /// Generate a key pair for exchange.
  KeyPair generateKeyPair() {
    final privateBytes = List<int>.generate(32, (_) => _random.nextInt(256));
    final publicBytes = List<int>.generate(32, (_) => _random.nextInt(256));
    return KeyPair(
      publicKey: base64Encode(publicBytes),
      privateKey: base64Encode(privateBytes),
    );
  }

  /// Derive shared secret from own private key and peer's public key.
  String deriveSharedSecret(String privateKey, String peerPublicKey) {
    _log.debug('Deriving shared secret');
    // In production: use X25519 or similar
    return base64Encode(base64Decode(privateKey).take(16).toList());
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
