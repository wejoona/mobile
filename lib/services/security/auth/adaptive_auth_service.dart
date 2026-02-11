import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/security/client_risk_score_service.dart';

/// Authentication level required based on risk.
enum AuthLevel { none, pin, biometric, mfa, blocked }

/// Determines authentication requirements based on risk signals.
///
/// Low-risk actions may proceed with PIN only, while high-risk actions
/// require biometric + TOTP verification.
class AdaptiveAuthService {
  static const _tag = 'AdaptiveAuth';
  final AppLogger _log = AppLogger(_tag);
  final ClientRiskScoreService _riskService;

  AdaptiveAuthService({required ClientRiskScoreService riskService})
      : _riskService = riskService;

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

    if (riskScore >= 0.8) return AuthLevel.blocked;
    if (riskScore >= 0.6) return AuthLevel.mfa;
    if (riskScore >= 0.3) return AuthLevel.biometric;
    if (riskScore >= 0.1) return AuthLevel.pin;
    return AuthLevel.none;
  }
}

final adaptiveAuthServiceProvider = Provider<AdaptiveAuthService>((ref) {
  return AdaptiveAuthService(
    riskService: ref.watch(clientRiskScoreServiceProvider),
  );
});
