import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Rule engine for compliance policy evaluation.
class ComplianceRuleEngine {
  static const _tag = 'RuleEngine';
  final AppLogger _log = AppLogger(_tag);
  final List<ComplianceRule> _rules = [];

  void registerRule(ComplianceRule rule) {
    _rules.add(rule);
    _log.debug('Registered rule: ${rule.name}');
  }

  /// Evaluate all rules against a transaction context.
  List<RuleViolation> evaluate(Map<String, dynamic> context) {
    final violations = <RuleViolation>[];
    for (final rule in _rules) {
      if (!rule.evaluate(context)) {
        violations.add(RuleViolation(ruleName: rule.name, severity: rule.severity));
      }
    }
    return violations;
  }

  int get ruleCount => _rules.length;
}

class ComplianceRule {
  final String name;
  final String severity;
  final bool Function(Map<String, dynamic>) evaluate;

  ComplianceRule({required this.name, required this.severity, required this.evaluate});
}

class RuleViolation {
  final String ruleName;
  final String severity;
  const RuleViolation({required this.ruleName, required this.severity});
}

final complianceRuleEngineProvider = Provider<ComplianceRuleEngine>((ref) {
  return ComplianceRuleEngine();
});
