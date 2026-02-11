import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Décision du moteur de risque
enum RiskDecision { approve, challenge, review, decline }

/// Entrée composite pour le moteur de décision
class RiskInput {
  final double transactionRiskScore;
  final double deviceRiskScore;
  final double velocityRiskScore;
  final double geoRiskScore;
  final double amlRiskScore;
  final bool isPep;
  final bool isSanctioned;

  const RiskInput({
    this.transactionRiskScore = 0.0,
    this.deviceRiskScore = 0.0,
    this.velocityRiskScore = 0.0,
    this.geoRiskScore = 0.0,
    this.amlRiskScore = 0.0,
    this.isPep = false,
    this.isSanctioned = false,
  });
}

/// Résultat de la décision de risque
class RiskDecisionResult {
  final RiskDecision decision;
  final double compositeScore;
  final Map<String, double> scoreBreakdown;
  final List<String> reasons;
  final String? requiredAction;
  final DateTime decidedAt;

  const RiskDecisionResult({
    required this.decision,
    required this.compositeScore,
    this.scoreBreakdown = const {},
    this.reasons = const [],
    this.requiredAction,
    required this.decidedAt,
  });
}

/// Moteur de décision de risque.
///
/// Combine tous les scores de risque (transaction, appareil,
/// vélocité, géographique, AML) pour prendre une décision.
class RiskDecisionEngine {
  static const _tag = 'RiskDecision';
  final AppLogger _log = AppLogger(_tag);

  // Pondérations des facteurs
  static const _weights = {
    'transaction': 0.25,
    'device': 0.15,
    'velocity': 0.20,
    'geo': 0.15,
    'aml': 0.25,
  };

  /// Évaluer et prendre une décision
  RiskDecisionResult evaluate(RiskInput input) {
    // Sanctions = rejet immédiat
    if (input.isSanctioned) {
      return RiskDecisionResult(
        decision: RiskDecision.decline,
        compositeScore: 1.0,
        reasons: ['Entité sanctionnée'],
        decidedAt: DateTime.now(),
      );
    }

    final breakdown = {
      'transaction': input.transactionRiskScore,
      'device': input.deviceRiskScore,
      'velocity': input.velocityRiskScore,
      'geo': input.geoRiskScore,
      'aml': input.amlRiskScore,
    };

    double composite = 0.0;
    for (final entry in breakdown.entries) {
      composite += entry.value * (_weights[entry.key] ?? 0.0);
    }

    // PEP: augmenter le score
    if (input.isPep) composite = (composite + 0.2).clamp(0.0, 1.0);

    final reasons = <String>[];
    if (input.transactionRiskScore > 0.6) reasons.add('Risque transaction élevé');
    if (input.deviceRiskScore > 0.6) reasons.add('Risque appareil élevé');
    if (input.velocityRiskScore > 0.6) reasons.add('Vélocité suspecte');
    if (input.geoRiskScore > 0.6) reasons.add('Risque géographique');
    if (input.amlRiskScore > 0.6) reasons.add('Alerte AML');
    if (input.isPep) reasons.add('Personne politiquement exposée');

    RiskDecision decision;
    String? action;
    if (composite < 0.3) {
      decision = RiskDecision.approve;
    } else if (composite < 0.6) {
      decision = RiskDecision.challenge;
      action = 'Authentification supplémentaire requise';
    } else if (composite < 0.85) {
      decision = RiskDecision.review;
      action = 'Examen manuel requis';
    } else {
      decision = RiskDecision.decline;
      action = 'Transaction refusée';
    }

    return RiskDecisionResult(
      decision: decision,
      compositeScore: composite,
      scoreBreakdown: breakdown,
      reasons: reasons,
      requiredAction: action,
      decidedAt: DateTime.now(),
    );
  }
}

final riskDecisionEngineProvider = Provider<RiskDecisionEngine>((ref) {
  return RiskDecisionEngine();
});
