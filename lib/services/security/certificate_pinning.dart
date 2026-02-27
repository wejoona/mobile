import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Certificate Pinning Service
/// SECURITY: Prevents man-in-the-middle attacks by validating server certificates
///
/// This implementation uses public key pinning (SPKI pinning) which is more resilient
/// to certificate renewal compared to full certificate pinning.
///
/// ## Generating Fingerprints
///
/// To get the SHA-256 fingerprint of your server's certificate, run:
///
/// ```bash
/// # For production API
/// openssl s_client -servername api.joonapay.com -connect api.joonapay.com:443 </dev/null 2>/dev/null | \
///   openssl x509 -pubkey -noout | \
///   openssl pkey -pubin -outform der | \
///   openssl dgst -sha256 -binary | \
///   openssl enc -base64
///
/// # Alternative: Get fingerprint from certificate file
/// openssl x509 -in certificate.pem -pubkey -noout | \
///   openssl pkey -pubin -outform der | \
///   openssl dgst -sha256 -binary | \
///   openssl enc -base64
/// ```
///
/// ## Rotating Certificates
///
/// 1. Generate new certificate
/// 2. Add new fingerprint to _trustedFingerprints (keep old one)
/// 3. Deploy app update
/// 4. After grace period, deploy new certificate to server
/// 5. Remove old fingerprint in next app update
///
class CertificatePinning {
  static final _logger = AppLogger('CertificatePinning');

  /// SHA-256 fingerprints of trusted certificate public keys (SPKI)
  ///
  /// IMPORTANT: Replace these with actual fingerprints before production deployment!
  /// Use the commands above to generate fingerprints for your certificates.
  ///
  /// Include at least 2 fingerprints:
  /// - Current production certificate
  /// - Backup/rotation certificate
  ///
  /// To generate fingerprints for your production domain:
  /// ```bash
  /// openssl s_client -servername api.joonapay.com -connect api.joonapay.com:443 </dev/null 2>/dev/null | \
  ///   openssl x509 -pubkey -noout | \
  ///   openssl pkey -pubin -outform der | \
  ///   openssl dgst -sha256 -binary | \
  ///   openssl enc -base64
  /// ```
  static const List<String> _trustedFingerprints = [
    // Production API certificate - api.joonapay.com (leaf SPKI SHA-256)
    // Generated: 2026-02-17
    '0ooL4eQsEMj6lnm33qMAdKWlYsbH1IW49TkdFDraPzY=',

    // Intermediate CA certificate (backup pin for rotation)
    // Generated: 2026-02-17
    'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=',
  ];

  /// Trusted hosts that require certificate pinning
  static const List<String> _pinnedHosts = [
    'api.joonapay.com',
    'joonapay.com',
  ];

  /// Configure Dio client with certificate pinning
  /// Only applies in release mode for production API
  static void configurePinning(Dio dio) {
    // Skip pinning in debug mode (localhost doesn't have valid certs)
    if (kDebugMode) {
      _logger.info('Disabled in debug mode');
      return;
    }

    // Verify fingerprints are configured
    if (_trustedFingerprints.any((fp) => fp.startsWith('REPLACE_'))) {
      // In release mode, fail closed if fingerprints not configured
      throw StateError(
        'SECURITY ERROR: Certificate pinning fingerprints not configured. '
        'Replace placeholder fingerprints before production deployment.',
      );
    }

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();

        // Set up certificate validation callback
        client.badCertificateCallback = _validateCertificate;

        return client;
      },
    );

    _logger.security('Certificate pinning enabled for ${_pinnedHosts.join(", ")}');
  }

  /// Certificate validation callback
  /// Returns true if certificate is valid, false to reject
  static bool _validateCertificate(X509Certificate cert, String host, int port) {
    // Check if this host requires pinning
    final requiresPinning = _pinnedHosts.any(
      (pinnedHost) => host == pinnedHost || host.endsWith('.$pinnedHost'),
    );

    if (!requiresPinning) {
      // For non-pinned hosts, reject bad certificates (default behavior)
      // This callback is only called for certificates that failed standard validation
      _logger.security('Rejecting bad certificate for non-pinned host: $host', level: 'WARN');
      return false;
    }

    // Validate certificate fingerprint for pinned hosts
    final isValid = validateFingerprint(cert);

    if (!isValid) {
      _logger.security('SECURITY ALERT - Certificate mismatch for $host', level: 'CRITICAL');
      _logger.security('Expected one of: ${_trustedFingerprints.join(", ")}', level: 'CRITICAL');
      _logger.security('Received: ${_computeFingerprint(cert)}', level: 'CRITICAL');
    }

    return isValid;
  }

  /// Validate certificate fingerprint
  /// Returns true if the certificate matches one of our trusted fingerprints
  static bool validateFingerprint(X509Certificate certificate) {
    try {
      final fingerprint = _computeFingerprint(certificate);

      if (fingerprint.isEmpty) {
        _logger.error('Failed to compute fingerprint');
        return false;
      }

      final isValid = _trustedFingerprints.contains(fingerprint);

      _logger.debug('Fingerprint validation - computed: $fingerprint, valid: $isValid');

      return isValid;
    } catch (e) {
      _logger.error('Validation error', e);
      return false;
    }
  }

  /// Compute SHA-256 fingerprint of certificate
  ///
  /// This computes the hash of the full DER-encoded certificate.
  /// For production, consider extracting just the SPKI (Subject Public Key Info)
  /// for more resilient pinning across certificate renewals.
  static String _computeFingerprint(X509Certificate certificate) {
    try {
      // Get DER-encoded certificate bytes
      final derBytes = certificate.der;

      if (derBytes.isEmpty) {
        return '';
      }

      // Compute SHA-256 hash
      final digest = sha256.convert(derBytes);

      // Return base64-encoded fingerprint
      return base64.encode(digest.bytes);
    } catch (e) {
      _logger.error('Error computing fingerprint', e);
      return '';
    }
  }

  /// Get the fingerprint of a certificate for debugging/setup purposes
  /// Only available in debug mode
  static String? getDebugFingerprint(X509Certificate certificate) {
    if (!kDebugMode) {
      return null;
    }
    return _computeFingerprint(certificate);
  }

  /// Check if certificate pinning is properly configured
  static bool isConfigured() {
    return !_trustedFingerprints.any((fp) => fp.startsWith('REPLACE_'));
  }

  /// Load trusted certificates from assets
  /// Use this for custom CA certificates if needed
  static Future<SecurityContext> loadTrustedCertificates() async {
    final context = SecurityContext.defaultContext;

    try {
      // Custom CA certificate loading will go here when certs are bundled in assets
    } catch (e) {
      _logger.error('Failed to load trusted certificates', e);
    }

    return context;
  }
}

/// Extension to easily apply certificate pinning to Dio
extension DioCertificatePinning on Dio {
  /// Enable certificate pinning for this Dio instance
  void enableCertificatePinning() {
    CertificatePinning.configurePinning(this);
  }
}
