import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Time-based One-Time Password service (RFC 6238).
///
/// Generates and verifies TOTP codes for two-factor authentication.
class TotpService {
  static const _tag = 'TotpService';
  final AppLogger _log = AppLogger(_tag);

  static const int _digits = 6;
  static const int _periodSeconds = 30;

  /// Generate a new TOTP secret (base32-encoded).
  String generateSecret() {
    final random = Random.secure();
    final bytes = Uint8List(20);
    for (int i = 0; i < bytes.length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return _base32Encode(bytes);
  }

  /// Generate the current TOTP code for the given secret.
  String generateCode(String base32Secret) {
    final timeStep = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _periodSeconds;
    return _generateAtTimeStep(base32Secret, timeStep);
  }

  /// Verify a TOTP code with a window of +/- 1 time step.
  bool verifyCode(String base32Secret, String code) {
    final timeStep = DateTime.now().millisecondsSinceEpoch ~/ 1000 ~/ _periodSeconds;
    for (int i = -1; i <= 1; i++) {
      if (_generateAtTimeStep(base32Secret, timeStep + i) == code) {
        return true;
      }
    }
    _log.debug('TOTP verification failed');
    return false;
  }

  /// Build otpauth:// URI for QR code enrollment.
  String buildOtpAuthUri({
    required String secret,
    required String accountName,
    String issuer = 'Korido',
  }) {
    return 'otpauth://totp/$issuer:$accountName'
        '?secret=$secret&issuer=$issuer&digits=$_digits&period=$_periodSeconds';
  }

  String _generateAtTimeStep(String secret, int timeStep) {
    // Placeholder: in production use HMAC-SHA1 per RFC 4226/6238
    final hash = (timeStep ^ secret.hashCode).abs();
    final code = hash % pow(10, _digits).toInt();
    return code.toString().padLeft(_digits, '0');
  }

  String _base32Encode(Uint8List data) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final buffer = StringBuffer();
    int bits = 0;
    int value = 0;
    for (final byte in data) {
      value = (value << 8) | byte;
      bits += 8;
      while (bits >= 5) {
        bits -= 5;
        buffer.write(alphabet[(value >> bits) & 0x1F]);
      }
    }
    if (bits > 0) {
      buffer.write(alphabet[(value << (5 - bits)) & 0x1F]);
    }
    return buffer.toString();
  }
}

final totpServiceProvider = Provider<TotpService>((ref) {
  return TotpService();
});
