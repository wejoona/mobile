import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/security/client_risk_score_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Authentication level required based on risk.
enum AuthLevel { none, pin, biometric, stepUp, blocked }

/// Determines authentication requirements based on risk signals.
///
/// Low-risk actions may proceed with PIN only. Higher-risk actions must use
/// the backend step-up flow so the server, not the device, owns the decision.
class AdaptiveAuthService {
  AdaptiveAuthService({required ClientRiskScoreService riskService})
    : _riskService = riskService;

  static const _tag = 'AdaptiveAuth';
  final AppLogger _log = const AppLogger(_tag);
  final ClientRiskScoreService _riskService;

  /// Determine required auth level for an action.
  Future<AuthLevel> requiredAuthLevel({
    required RiskAction action,
    double? transactionAmount,
  }) async {
    final riskScore = await _riskService.calculateRiskScore(
      action: action,
      transactionAmount: transactionAmount,
    );

    _log.debug('Risk score for $action: ${riskScore.toStringAsFixed(2)}');

    if (riskScore >= 0.8) {
      return AuthLevel.blocked;
    }
    if (riskScore >= 0.6) {
      return AuthLevel.stepUp;
    }
    if (riskScore >= 0.3) {
      return AuthLevel.biometric;
    }
    if (riskScore >= 0.1) {
      return AuthLevel.pin;
    }
    return AuthLevel.none;
  }
}

final adaptiveAuthServiceProvider = Provider<AdaptiveAuthService>(
  (ref) => AdaptiveAuthService(
    riskService: ref.watch(clientRiskScoreServiceProvider),
  ),
);
