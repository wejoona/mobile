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
      sha256Pins: [
        // Leaf SPKI SHA-256 for Korido API, generated 2026-06-03.
        'DcXImxqsw11wXDKaem3Be3mcFibKSosQGkPpNOw9Zuw=',
        // Google Trust Services WE1 intermediate SPKI backup pin.
        'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=',
      ],
    ),
    CertificatePinningConfig(
      host: 'joonapay.com',
      sha256Pins: [
        // Leaf SPKI SHA-256 for joonapay.com, generated 2026-06-03.
        'vz/Oj4HDd7i5iGnOiGk+BAZa/i62MKNdA74TWH/6pew=',
        'kIdp6NNEd8wsugYyyIYFsi1ylMCED3hZbSR8ZFsa/A4=',
      ],
    ),
  ];

  /// Staging is intentionally unpinned until a stable staging API certificate
  /// exists. Production pinning remains enforced through [productionPins].
  static const List<CertificatePinningConfig> stagingPins = [];

  static List<CertificatePinningConfig> getPins({required bool isProduction}) =>
      isProduction ? productionPins : stagingPins;

  static bool validatePin(
    String host,
    String pinHash, {
    required bool isProduction,
  }) {
    final pins = getPins(isProduction: isProduction);
    final config = pins.where((p) => host.endsWith(p.host)).firstOrNull;
    if (config == null || config.isExpired) {
      return true; // Pas de pin = accepter
    }
    return config.sha256Pins.contains(pinHash);
  }
}

final certificatePinRegistryProvider = Provider<CertificatePinRegistry>(
  (ref) => CertificatePinRegistry(),
);
