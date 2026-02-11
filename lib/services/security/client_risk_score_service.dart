import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:usdc_wallet/services/security/device_fingerprint_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Actions that can be risk-scored on the client side.
enum RiskAction { login, transfer, withdrawal, largeTransaction }

/// Client-side risk score service.
///
/// Computes a score 0.0 (safe) to 1.0 (risky) from local device signals.
/// Sent to backend via `X-Risk-Score` header so the server can combine it
/// with its own signals for adaptive security decisions.
class ClientRiskScoreService {
  final DeviceFingerprintService _fingerprintService;

  ClientRiskScoreService({required DeviceFingerprintService fingerprintService})
      : _fingerprintService = fingerprintService;

  /// Calculate client-side risk score for the given action.
  ///
  /// Factors considered:
  /// - Device compromised (jailbroken/rooted): +0.40
  /// - Running on emulator: +0.25
  /// - No biometrics available: +0.10
  /// - Debug mode: +0.05
  /// - Action-specific base risk
  Future<double> calculateRiskScore({
    RiskAction action = RiskAction.transfer,
    double? transactionAmount,
  }) async {
    double score = 0.0;

    try {
      final fp = await _fingerprintService.collect();

      // Device integrity signals
      if (fp.isCompromised) score += 0.40;
      if (!fp.isPhysicalDevice) score += 0.25;
      if (!fp.biometricsAvailable) score += 0.10;
    } catch (e) {
      // If we can't collect fingerprint, that's suspicious
      score += 0.30;
      AppLogger('ClientRisk').error('Fingerprint collection failed', e);
    }

    // Debug mode
    if (kDebugMode) score += 0.05;

    // Action-specific base risk
    switch (action) {
      case RiskAction.login:
        score += 0.0;
        break;
      case RiskAction.transfer:
        score += 0.05;
        break;
      case RiskAction.withdrawal:
        score += 0.10;
        break;
      case RiskAction.largeTransaction:
        score += 0.15;
        break;
    }

    // Transaction amount factor
    if (transactionAmount != null) {
      if (transactionAmount > 10000) {
        score += 0.15;
      } else if (transactionAmount > 1000) {
        score += 0.05;
      }
    }

    return score.clamp(0.0, 1.0);
  }
}

/// Provider for ClientRiskScoreService
final clientRiskScoreServiceProvider =
    Provider<ClientRiskScoreService>((ref) {
  return ClientRiskScoreService(
    fingerprintService: ref.watch(deviceFingerprintServiceProvider),
  );
});
