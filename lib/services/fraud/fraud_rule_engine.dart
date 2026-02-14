import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Type de règle de fraude
enum FraudRuleType {
  amountThreshold,
  velocityLimit,
  deviceTrust,
  geoRestriction,
  behavioralMatch,
  blacklist,
}

class FraudRule {
  final String ruleId;
  final String name;
  final FraudRuleType type;
  final bool isActive;
  final Map<String, dynamic> conditions;
  final double weight;

  const FraudRule({
    required this.ruleId,
    required this.name,
    required this.type,
    required this.isActive,
    this.conditions = const {},
    this.weight = 1.0,
  });
}

class FraudRuleResult {
  final String ruleId;
  final bool triggered;
  final double score;
  final String? reason;

  const FraudRuleResult({
    required this.ruleId,
    required this.triggered,
    required this.score,
    this.reason,
  });
}

/// Moteur de règles de fraude côté client.
///
/// Pré-évalue les transactions localement avant
/// validation serveur.
class FraudRuleEngine {
  static const _tag = 'FraudRuleEngine';
  // ignore: unused_field
  final AppLogger _log = AppLogger(_tag);
  final List<FraudRule> _rules;

  FraudRuleEngine({List<FraudRule> rules = const []}) : _rules = rules;

  List<FraudRuleResult> evaluate({
    required double amount,
    required String deviceId,
    required String recipientId,
    String? country,
  }) {
    return _rules.where((r) => r.isActive).map((rule) {
      switch (rule.type) {
        case FraudRuleType.amountThreshold:
          final max = (rule.conditions['maxAmount'] as num?)?.toDouble() ?? double.infinity;
          return FraudRuleResult(
            ruleId: rule.ruleId,
            triggered: amount > max,
            score: amount > max ? rule.weight : 0,
            reason: amount > max ? 'Montant dépasse ${max}' : null,
          );
        case FraudRuleType.blacklist:
          final blacklisted = List<String>.from(rule.conditions['recipientIds'] ?? []);
          final hit = blacklisted.contains(recipientId);
          return FraudRuleResult(
            ruleId: rule.ruleId,
            triggered: hit,
            score: hit ? rule.weight : 0,
            reason: hit ? 'Bénéficiaire sur liste noire' : null,
          );
        default:
          return FraudRuleResult(ruleId: rule.ruleId, triggered: false, score: 0);
      }
    }).toList();
  }
}

final fraudRuleEngineProvider = Provider<FraudRuleEngine>((ref) {
  return FraudRuleEngine();
});
