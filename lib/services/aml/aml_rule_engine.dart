import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Type de règle AML
enum AmlRuleType {
  threshold,
  velocity,
  pattern,
  geographic,
  behavioral,
  structuring,
}

/// Règle AML configurable
class AmlRule {
  final String ruleId;
  final String name;
  final AmlRuleType type;
  final bool isActive;
  final Map<String, dynamic> parameters;
  final String description;

  const AmlRule({
    required this.ruleId,
    required this.name,
    required this.type,
    required this.isActive,
    this.parameters = const {},
    required this.description,
  });

  factory AmlRule.fromJson(Map<String, dynamic> json) => AmlRule(
    ruleId: json['ruleId'] as String,
    name: json['name'] as String,
    type: AmlRuleType.values.byName(json['type'] as String),
    isActive: json['isActive'] as bool? ?? true,
    parameters: Map<String, dynamic>.from(json['parameters'] ?? {}),
    description: json['description'] as String,
  );
}

/// Résultat de l'évaluation d'une règle
class RuleEvaluationResult {
  final String ruleId;
  final bool triggered;
  final double score;
  final String? detail;

  const RuleEvaluationResult({
    required this.ruleId,
    required this.triggered,
    required this.score,
    this.detail,
  });
}

/// Moteur de règles AML côté client.
///
/// Évalue les transactions localement avant envoi au serveur
/// pour un pré-filtrage rapide.
class AmlRuleEngine {
  final List<AmlRule> _rules;

  AmlRuleEngine({List<AmlRule> rules = const []}) : _rules = rules;

  /// Évaluer une transaction contre toutes les règles actives
  List<RuleEvaluationResult> evaluate({
    required double amount,
    required String currency,
    required String recipientCountry,
    int? dailyTransactionCount,
    double? dailyTotal,
  }) {
    final results = <RuleEvaluationResult>[];
    for (final rule in _rules.where((r) => r.isActive)) {
      switch (rule.type) {
        case AmlRuleType.threshold:
          final threshold = (rule.parameters['threshold'] as num?)?.toDouble() ?? double.infinity;
          results.add(RuleEvaluationResult(
            ruleId: rule.ruleId,
            triggered: amount >= threshold,
            score: amount >= threshold ? 0.8 : 0.0,
            detail: amount >= threshold ? 'Montant dépasse le seuil de $threshold' : null,
          ));
          break;
        case AmlRuleType.velocity:
          final maxCount = (rule.parameters['maxDailyCount'] as num?)?.toInt() ?? 999;
          final count = dailyTransactionCount ?? 0;
          results.add(RuleEvaluationResult(
            ruleId: rule.ruleId,
            triggered: count >= maxCount,
            score: count >= maxCount ? 0.7 : 0.0,
          ));
          break;
        case AmlRuleType.geographic:
          final highRisk = List<String>.from(rule.parameters['highRiskCountries'] ?? []);
          final isHigh = highRisk.contains(recipientCountry);
          results.add(RuleEvaluationResult(
            ruleId: rule.ruleId,
            triggered: isHigh,
            score: isHigh ? 0.6 : 0.0,
          ));
          break;
        default:
          results.add(RuleEvaluationResult(ruleId: rule.ruleId, triggered: false, score: 0.0));
      }
    }
    return results;
  }
}

final amlRuleEngineProvider = Provider<AmlRuleEngine>((ref) {
  return AmlRuleEngine();
});
