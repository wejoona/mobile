import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration des certificats épinglés par environnement.
class CertificatePinningConfig {
  const CertificatePinningConfig({
    required this.host,
    required this.sha256Pins,
    this.includeSubdomains = true,
    this.expiresAt,
  });

  final String host;
  final List<String> sha256Pins;
  final bool includeSubdomains;
  final DateTime? expiresAt;

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Registre des pins de certificats pour l'application.
class CertificatePinRegistry {
  static const List<CertificatePinningConfig> productionPins = [
    CertificatePinningConfig(
      host: 'korido-api.joonapay.com',
      includeSubdomains: false,
      sha256Pins: [
        // Leaf SPKI SHA-256 for Korido API, verified 2026-06-20.
        'DcXImxqsw11wXDKaem3Be3mcFibKSosQGkPpNOw9Zuw=',
        // Google Trust Services WE1 intermediate SPKI backup pin.
        'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=',
      ],
    ),
    CertificatePinningConfig(
      host: 'joonapay.com',
      includeSubdomains: false,
      sha256Pins: [
        // Leaf SPKI SHA-256 for joonapay.com, verified 2026-06-20.
        'dnwFNJb53pgHXDzto90QqivYDXDUKaYHYU7OxVOxgVw=',
        // Previous apex leaf SPKI SHA-256 kept as a rollover pin.
        'vz/Oj4HDd7i5iGnOiGk+BAZa/i62MKNdA74TWH/6pew=',
        'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=',
      ],
    ),
  ];

  // Joonalabs staging DNS/TLS is provisioned after the domain enters
  // Cloudflare. Keep staging on platform TLS until the live certificate can be
  // fetched and pinned truthfully.
  static const List<CertificatePinningConfig> stagingPins = [];

  static List<CertificatePinningConfig> getPins({required bool isProduction}) =>
      isProduction ? productionPins : stagingPins;

  static bool validatePin(
    String host,
    String pinHash, {
    required bool isProduction,
  }) {
    final pins = getPins(isProduction: isProduction);
    final config = pins.where((p) {
      if (host == p.host) {
        return true;
      }
      return p.includeSubdomains && host.endsWith('.${p.host}');
    }).firstOrNull;
    if (config == null || config.isExpired) {
      return true; // No configured pin: fall back to platform TLS.
    }
    return config.sha256Pins.contains(pinHash);
  }
}

final certificatePinRegistryProvider = Provider<CertificatePinRegistry>(
  (ref) => CertificatePinRegistry(),
);
