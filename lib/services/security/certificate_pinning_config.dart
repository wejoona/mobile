import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration des certificats épinglés par environnement.
class CertificatePinningConfig {
  final String host;
  final List<String> sha256Pins;
  final bool includeSubdomains;
  final DateTime? expiresAt;

  const CertificatePinningConfig({
    required this.host,
    required this.sha256Pins,
    this.includeSubdomains = true,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Registre des pins de certificats pour l'application.
class CertificatePinRegistry {
  static const List<CertificatePinningConfig> productionPins = [
    CertificatePinningConfig(
      host: 'api.korido.app',
      sha256Pins: [
        // Pin primaire et de secours — à remplacer par les vrais hashes
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ],
    ),
    CertificatePinningConfig(
      host: 'auth.korido.app',
      sha256Pins: [
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ],
    ),
  ];

  static const List<CertificatePinningConfig> stagingPins = [
    CertificatePinningConfig(
      host: 'api-staging.korido.app',
      sha256Pins: [
        'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
      ],
    ),
  ];

  static List<CertificatePinningConfig> getPins({required bool isProduction}) {
    return isProduction ? productionPins : stagingPins;
  }

  static bool validatePin(String host, String pinHash, {required bool isProduction}) {
    final pins = getPins(isProduction: isProduction);
    final config = pins.where((p) => host.endsWith(p.host)).firstOrNull;
    if (config == null || config.isExpired) return true; // Pas de pin = accepter
    return config.sha256Pins.contains(pinHash);
  }
}

final certificatePinRegistryProvider = Provider<CertificatePinRegistry>((ref) {
  return CertificatePinRegistry();
});
