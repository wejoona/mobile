import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Time-based One-Time Password service (RFC 6238).
///
/// Authenticator-app MFA is intentionally not device-local in Korido.
/// Enrollment, secret storage, and verification must be backend-backed before
/// this service can be enabled.
class TotpService {
  static const _unsupportedMessage =
      'Authenticator-app MFA is not available in this mobile build. Use backend risk step-up instead.';

  /// Generate a new TOTP secret (base32-encoded).
  String generateSecret() => throw UnsupportedError(_unsupportedMessage);

  /// Generate the current TOTP code for the given secret.
  String generateCode(String base32Secret) =>
      throw UnsupportedError(_unsupportedMessage);

  /// Verify a TOTP code with a window of +/- 1 time step.
  bool verifyCode(String base32Secret, String code) => false;

  /// Build otpauth:// URI for QR code enrollment.
  String buildOtpAuthUri({
    required String secret,
    required String accountName,
    String issuer = 'Korido',
  }) => throw UnsupportedError(_unsupportedMessage);
}

final totpServiceProvider = Provider<TotpService>((ref) => TotpService());
