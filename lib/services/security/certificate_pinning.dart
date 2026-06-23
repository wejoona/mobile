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
/// This Dio implementation uses exact-host leaf certificate DER pins because
/// Dart's [X509Certificate] exposes DER bytes directly. Native/platform pinning
/// can use SPKI pins separately when that path is wired.
///
/// ## Generating Fingerprints
///
/// To get the SHA-256 fingerprint of your server's certificate, run:
///
/// ```bash
/// # Full leaf certificate DER hash for this Dart validator
/// openssl s_client -servername korido-api.joonapay.com -connect korido-api.joonapay.com:443 </dev/null 2>/dev/null | \
///   openssl x509 -outform der | \
///   openssl dgst -sha256 -binary | \
///   openssl enc -base64
///
/// # Android network-security-config uses SPKI pins instead:
/// openssl s_client -servername korido-api.joonapay.com -connect korido-api.joonapay.com:443 </dev/null 2>/dev/null | \
///   openssl x509 -pubkey -noout | \
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
  static const _logger = AppLogger('CertificatePinning');

  /// SHA-256 fingerprints of trusted leaf certificate DER bytes by host.
  ///
  /// Dart exposes the leaf certificate DER, not SPKI bytes, from
  /// [X509Certificate]. Keep these pins exact-host scoped so staging and future
  /// service hosts do not inherit production API pins by accident.
  static const Map<String, List<String>> _trustedFingerprintsByHost = {
    'staging-korido-api.joonapay.com': [
      // Leaf DER SHA-256, verified against live certificate on 2026-06-20.
      'gvcwFV4jHJrKyc2rrHFNlZbenxWnWywAezu5tpkv7is=',
    ],
    'korido-api.joonapay.com': [
      // Leaf DER SHA-256, verified against live certificate on 2026-06-20.
      'gvcwFV4jHJrKyc2rrHFNlZbenxWnWywAezu5tpkv7is=',
      // Previous API/apex leaf DER SHA-256 kept as a rollover pin.
      'BWCq7vFEHnLEBB9FD9tOUTlIeFRPNHIJL7vPHgNjodc=',
    ],
    'joonapay.com': [
      // Leaf DER SHA-256, verified against live certificate on 2026-06-20.
      'xjdxghsWoSZ9sfkyskfb2cmBgPZ/qKozfMWw3lzb/+E=',
      // Previous apex leaf DER SHA-256 kept as a rollover pin.
      'BWCq7vFEHnLEBB9FD9tOUTlIeFRPNHIJL7vPHgNjodc=',
    ],
  };

  /// Configure Dio client with certificate pinning
  /// Only applies in release mode for production API
  static bool configurePinning(Dio dio, {bool forceForTesting = false}) {
    // Skip pinning in debug mode (localhost doesn't have valid certs)
    if (kDebugMode && !forceForTesting) {
      _logger.info('Disabled in debug mode');
      return false;
    }

    // Verify fingerprints are configured
    if (!isConfigured()) {
      // In release mode, fail closed if fingerprints not configured
      throw StateError(
        'SECURITY ERROR: Certificate pinning fingerprints not configured. '
        'Replace placeholder fingerprints before production deployment.',
      );
    }

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: HttpClient.new,
      validateCertificate: _validateTrustedCertificate,
    );

    _logger.security(
      'Certificate pinning enabled for ${_trustedFingerprintsByHost.keys.join(", ")}',
    );
    return true;
  }

  /// Certificate validation callback
  /// Returns true if certificate is valid, false to reject
  static bool _validateTrustedCertificate(
    X509Certificate? cert,
    String host,
    int port,
  ) {
    // Check if this host requires pinning
    final expectedFingerprints = _trustedFingerprintsByHost[host];
    final requiresPinning = expectedFingerprints != null;

    if (!requiresPinning) {
      // Standard platform TLS validation has already accepted this
      // certificate chain. Preserve normal behavior for non-pinned hosts.
      return true;
    }

    if (cert == null) {
      _logger.security(
        'SECURITY ALERT - Missing certificate for pinned host $host',
        level: 'CRITICAL',
      );
      return false;
    }

    // Validate certificate fingerprint for pinned hosts
    final isValid = validateFingerprint(
      cert,
      expectedFingerprints: expectedFingerprints,
    );

    if (!isValid) {
      _logger
        ..security(
          'SECURITY ALERT - Certificate mismatch for $host',
          level: 'CRITICAL',
        )
        ..security(
          'Expected one of: ${expectedFingerprints.join(", ")}',
          level: 'CRITICAL',
        )
        ..security('Received: ${_computeFingerprint(cert)}', level: 'CRITICAL');
    }

    return isValid;
  }

  /// Validate certificate fingerprint
  /// Returns true if the certificate matches one of our trusted fingerprints
  static bool validateFingerprint(
    X509Certificate certificate, {
    List<String>? expectedFingerprints,
  }) {
    try {
      final fingerprint = _computeFingerprint(certificate);

      if (fingerprint.isEmpty) {
        _logger.error('Failed to compute fingerprint');
        return false;
      }

      final trustedFingerprints =
          expectedFingerprints ??
          _trustedFingerprintsByHost.values.expand((pins) => pins).toList();
      final isValid = trustedFingerprints.contains(fingerprint);

      _logger.debug(
        'Fingerprint validation - computed: $fingerprint, valid: $isValid',
      );

      return isValid;
    } on Object catch (e) {
      _logger.error('Validation error', e);
      return false;
    }
  }

  /// Compute SHA-256 fingerprint of certificate
  ///
  /// This computes the hash of the full DER-encoded certificate because Dart's
  /// [X509Certificate] does not expose SPKI bytes directly.
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
    } on Object catch (e) {
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
  static bool isConfigured() =>
      _trustedFingerprintsByHost.isNotEmpty &&
      _trustedFingerprintsByHost.values.every(
        (pins) =>
            pins.isNotEmpty &&
            pins.every(
              (fingerprint) =>
                  fingerprint.isNotEmpty && !fingerprint.startsWith('REPLACE_'),
            ),
      );

  @visibleForTesting
  static bool hostRequiresPinning(String host) =>
      _trustedFingerprintsByHost.containsKey(host);

  static Map<String, List<String>> trustedFingerprintsByHost() =>
      Map<String, List<String>>.unmodifiable(
        _trustedFingerprintsByHost.map(
          (host, pins) => MapEntry(host, List<String>.unmodifiable(pins)),
        ),
      );

  @visibleForTesting
  static List<String> trustedFingerprintsForHost(String host) =>
      List.unmodifiable(_trustedFingerprintsByHost[host] ?? const []);

  /// Load trusted certificates from assets
  /// Use this for custom CA certificates if needed
  static Future<SecurityContext> loadTrustedCertificates() async {
    final context = SecurityContext.defaultContext;

    try {
      // Custom CA certificate loading will go here when certs are bundled in assets
    } on Object catch (e) {
      _logger.error('Failed to load trusted certificates', e);
    }

    return context;
  }
}

/// Extension to easily apply certificate pinning to Dio
extension DioCertificatePinning on Dio {
  /// Enable certificate pinning for this Dio instance
  bool enableCertificatePinning() => CertificatePinning.configurePinning(this);
}
