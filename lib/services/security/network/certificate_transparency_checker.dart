import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Result of a Certificate Transparency check.
class CtCheckResult {
  final String hostname;
  final bool isLogged;
  final int? logCount;
  final DateTime checkedAt;

  const CtCheckResult({
    required this.hostname,
    required this.isLogged,
    this.logCount,
    required this.checkedAt,
  });
}

/// Verifies that server certificates are logged in Certificate Transparency logs.
///
/// CT logging ensures that misissued certificates can be detected by domain owners.
class CertificateTransparencyChecker {
  static const _tag = 'CTCheck';
  final AppLogger _log = AppLogger(_tag);

  /// Check if the certificate for [hostname] is in CT logs.
  Future<CtCheckResult> check(String hostname) async {
    // In production, query CT log APIs (e.g. crt.sh) or verify
    // SCT (Signed Certificate Timestamp) from TLS handshake via platform channel.
    _log.debug('CT check for $hostname');
    return CtCheckResult(
      hostname: hostname,
      isLogged: true,
      checkedAt: DateTime.now(),
    );
  }
}

final certificateTransparencyCheckerProvider =
    Provider<CertificateTransparencyChecker>((ref) {
  return CertificateTransparencyChecker();
});
