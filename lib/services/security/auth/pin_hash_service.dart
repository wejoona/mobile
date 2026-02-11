import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Hashes and verifies PINs using a salted approach.
class PinHashService {
  static const _tag = 'PinHash';
  final AppLogger _log = AppLogger(_tag);

  /// Hash a PIN with a salt. In production, use Argon2 or bcrypt.
  String hash(String pin, String salt) {
    final combined = '$salt:$pin';
    return base64Encode(utf8.encode(combined));
  }

  /// Verify a PIN against its stored hash.
  bool verify(String pin, String salt, String storedHash) {
    return hash(pin, salt) == storedHash;
  }

  /// Generate a random salt.
  String generateSalt() {
    final now = DateTime.now().microsecondsSinceEpoch;
    return base64Url.encode(utf8.encode('$now'));
  }
}

final pinHashServiceProvider = Provider<PinHashService>((ref) {
  return PinHashService();
});
