import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Encrypts messages for P2P communication.
///
/// P2P message encryption is not product-ready yet. Keep this service as an
/// explicit fail-closed boundary so no feature accidentally ships base64 or
/// another reversible encoding while presenting it as encryption.
class MessageEncryptor {
  static const _tag = 'MsgEncrypt';
  final AppLogger _log = AppLogger(_tag);

  /// Encrypt a message payload.
  String encrypt(String plaintext, String recipientPublicKey) {
    _log.error('P2P message encryption requested before implementation');
    throw UnsupportedError(
      'P2P message encryption is not implemented; plaintext transmission blocked.',
    );
  }

  /// Decrypt a received message.
  String decrypt(String ciphertext, String privateKey) {
    throw UnsupportedError('P2P message decryption is not implemented.');
  }
}

final messageEncryptorProvider = Provider<MessageEncryptor>((ref) {
  return MessageEncryptor();
});
