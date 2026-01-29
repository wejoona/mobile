import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'pin_config.dart';

/// Secure PIN hashing utilities using PBKDF2.
///
/// Uses PBKDF2-HMAC-SHA256 with configurable iterations.
/// PIN is never stored in plain text.
class PinHasher {
  PinHasher._();

  /// Hash a PIN with a provided salt.
  ///
  /// Uses PBKDF2-HMAC-SHA256 with high iterations to resist brute-force.
  /// Since PINs are only 4-6 digits, strong KDF is essential.
  static String hashPin(String pin, String salt) {
    final saltBytes = utf8.encode(salt);
    final pinBytes = utf8.encode(pin);

    final derivedKey = pbkdf2(
      pinBytes,
      saltBytes,
      PinConfig.pbkdf2Iterations,
      PinConfig.keyLength,
    );

    return base64.encode(derivedKey);
  }

  /// Hash a PIN for transmission to backend.
  ///
  /// Uses fewer iterations since backend will re-hash for storage.
  /// Provides defense-in-depth: even if intercepted, PIN can't be recovered
  /// without knowing the salt and performing brute-force.
  static String hashPinForTransmission(String pin) {
    final saltBytes = utf8.encode(PinConfig.transmissionSalt);
    final pinBytes = utf8.encode(pin);

    final derivedKey = pbkdf2(
      pinBytes,
      saltBytes,
      PinConfig.pbkdf2TransmissionIterations,
      PinConfig.keyLength,
    );

    return base64.encode(derivedKey);
  }

  /// Generate a cryptographically secure random salt.
  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(
      PinConfig.saltLength,
      (i) => random.nextInt(256),
    );
    return base64.encode(bytes);
  }

  /// PBKDF2 key derivation function.
  ///
  /// Implements RFC 2898 PBKDF2 with HMAC-SHA256.
  static List<int> pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final numBlocks = (keyLength + 31) ~/ 32; // SHA256 produces 32 bytes
    final derivedKey = <int>[];

    for (var blockNum = 1; blockNum <= numBlocks; blockNum++) {
      // Encode block number as big-endian 4-byte integer
      final blockBytes = [
        (blockNum >> 24) & 0xff,
        (blockNum >> 16) & 0xff,
        (blockNum >> 8) & 0xff,
        blockNum & 0xff,
      ];

      // U1 = PRF(Password, Salt || INT(i))
      var u = hmac.convert([...salt, ...blockBytes]).bytes;
      var result = List<int>.from(u);

      // Subsequent iterations: Ui = PRF(Password, U(i-1))
      for (var i = 1; i < iterations; i++) {
        u = hmac.convert(u).bytes;
        // XOR with accumulated result
        for (var j = 0; j < result.length; j++) {
          result[j] ^= u[j];
        }
      }

      derivedKey.addAll(result);
    }

    return derivedKey.sublist(0, keyLength);
  }

  /// Verify a PIN against a stored hash.
  static bool verifyPin(String pin, String storedHash, String salt) {
    final inputHash = hashPin(pin, salt);
    return _constantTimeCompare(inputHash, storedHash);
  }

  /// Constant-time string comparison to prevent timing attacks.
  static bool _constantTimeCompare(String a, String b) {
    if (a.length != b.length) return false;

    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }
}
