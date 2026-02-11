import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Security score breakdown.
class SecurityScoreBreakdown {
  final int overallScore;
  final int deviceScore;
  final int networkScore;
  final int authScore;
  final int behaviorScore;
  final List<String> recommendations;
  final DateTime calculatedAt;

  const SecurityScoreBreakdown({
    required this.overallScore,
    required this.deviceScore,
    required this.networkScore,
    required this.authScore,
    required this.behaviorScore,
    this.recommendations = const [],
    required this.calculatedAt,
  });

  String get grade {
    if (overallScore >= 90) return 'A';
    if (overallScore >= 80) return 'B';
    if (overallScore >= 70) return 'C';
    if (overallScore >= 60) return 'D';
    return 'F';
  }
}

/// Calculates an overall security score for the app installation.
///
/// Combines device integrity, network security, authentication strength,
/// and user behavior into a single score 0-100.
class AppSecurityScoreCalculator {
  static const _tag = 'SecurityScore';
  final AppLogger _log = AppLogger(_tag);

  /// Calculate the security score.
  SecurityScoreBreakdown calculate({
    required bool deviceSecure,
    required bool hasBiometrics,
    required bool hasMfa,
    required bool hasStrongPin,
    required double networkTrustScore,
    required int recentFailedLogins,
    required bool vpnActive,
  }) {
    int device = 100;
    int network = 100;
    int auth = 100;
    int behavior = 100;
    final recommendations = <String>[];

    // Device
    if (!deviceSecure) {
      device -= 50;
      recommendations.add('Appareil compromis detecte');
    }
    if (!hasBiometrics) {
      device -= 15;
      recommendations.add('Activez la biometrie pour plus de securite');
    }

    // Network
    network = (networkTrustScore * 100).toInt();
    if (vpnActive) {
      network -= 10;
    }

    // Auth
    if (!hasMfa) {
      auth -= 30;
      recommendations.add('Activez l\'authentification a deux facteurs');
    }
    if (!hasStrongPin) {
      auth -= 20;
      recommendations.add('Choisissez un PIN plus fort');
    }

    // Behavior
    if (recentFailedLogins > 0) {
      behavior -= recentFailedLogins * 10;
    }

    device = device.clamp(0, 100);
    network = network.clamp(0, 100);
    auth = auth.clamp(0, 100);
    behavior = behavior.clamp(0, 100);

    final overall = ((device + network + auth + behavior) / 4).round();

    return SecurityScoreBreakdown(
      overallScore: overall,
      deviceScore: device,
      networkScore: network,
      authScore: auth,
      behaviorScore: behavior,
      recommendations: recommendations,
      calculatedAt: DateTime.now(),
    );
  }
}

final appSecurityScoreCalculatorProvider =
    Provider<AppSecurityScoreCalculator>((ref) {
  return AppSecurityScoreCalculator();
});
