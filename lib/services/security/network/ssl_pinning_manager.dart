import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages SSL certificate pinning for API connections.
///
/// Validates server certificates against a set of pinned public key hashes
/// to prevent man-in-the-middle attacks even when a rogue CA is trusted.
class SslPinningManager {
  static const _tag = 'SslPinning';
  final AppLogger _log = AppLogger(_tag);

  /// SHA-256 hashes of pinned certificate public keys.
  final List<String> _pinnedHashes;

  /// Whether pinning is currently enforced.
  bool _enforced = true;

  SslPinningManager({required List<String> pinnedHashes})
      : _pinnedHashes = List.unmodifiable(pinnedHashes);

  /// Create an [HttpClient] with certificate pinning applied.
  HttpClient createPinnedClient() {
    final client = HttpClient();
    client.badCertificateCallback = _verifyCertificate;
    return client;
  }

  /// Callback used by [HttpClient] to verify server certificates.
  bool _verifyCertificate(X509Certificate cert, String host, int port) {
    if (!_enforced) return true;

    try {
      final certHash = _sha256Fingerprint(cert);
      final trusted = _pinnedHashes.contains(certHash);
      if (!trusted) {
        _log.error(
          'Certificate pinning failed for $host:$port. '
          'Hash: $certHash',
        );
      }
      return trusted;
    } catch (e) {
      _log.error('Certificate verification error', e);
      return false;
    }
  }

  /// Compute SHA-256 fingerprint of the certificate DER encoding.
  String _sha256Fingerprint(X509Certificate cert) {
    final der = cert.der;
    final digest = _computeSha256(der);
    return base64Encode(digest);
  }

  /// Simple SHA-256 via dart:convert (platform-level).
  List<int> _computeSha256(List<int> data) {
    // In production, use crypto package or platform channel.
    // Placeholder: returns the raw DER prefix as hash stand-in.
    // Replace with: import 'package:crypto/crypto.dart'; sha256.convert(data).bytes;
    return data.take(32).toList();
  }

  /// Temporarily disable pinning (e.g. during debug).
  void setEnforced(bool enforced) {
    _enforced = enforced;
    _log.debug('SSL pinning enforcement: $_enforced');
  }

  bool get isEnforced => _enforced;

  /// Reload pins from bundled asset.
  Future<void> reloadPinsFromAsset(String assetPath) async {
    try {
      final raw = await rootBundle.loadString(assetPath);
      final pins = LineSplitter.split(raw)
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .toList();
      _pinnedHashes
        ..clear()
        ..addAll(pins);
      _log.debug('Reloaded ${pins.length} certificate pins');
    } catch (e) {
      _log.error('Failed to reload pins from $assetPath', e);
    }
  }
}

/// Provider for [SslPinningManager].
final sslPinningManagerProvider = Provider<SslPinningManager>((ref) {
  return SslPinningManager(pinnedHashes: const [
    // Production API pin (rotate quarterly)
    'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
  ]);
});
