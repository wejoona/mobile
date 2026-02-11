/// Sévérité de l'alerte AML
enum AmlAlertSeverity { info, warning, critical }

/// Statut de l'alerte
enum AmlAlertStatus { newAlert, acknowledged, investigating, dismissed, escalated }

/// Modèle d'alerte AML
class AmlAlert {
  final String alertId;
  final String userId;
  final AmlAlertSeverity severity;
  final AmlAlertStatus status;
  final String ruleId;
  final String ruleName;
  final String description;
  final String? transactionId;
  final double? amount;
  final DateTime createdAt;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;

  const AmlAlert({
    required this.alertId,
    required this.userId,
    required this.severity,
    required this.status,
    required this.ruleId,
    required this.ruleName,
    required this.description,
    this.transactionId,
    this.amount,
    required this.createdAt,
    this.acknowledgedAt,
    this.acknowledgedBy,
  });

  factory AmlAlert.fromJson(Map<String, dynamic> json) => AmlAlert(
    alertId: json['alertId'] as String,
    userId: json['userId'] as String,
    severity: AmlAlertSeverity.values.byName(json['severity'] as String),
    status: AmlAlertStatus.values.byName(json['status'] as String),
    ruleId: json['ruleId'] as String,
    ruleName: json['ruleName'] as String,
    description: json['description'] as String,
    transactionId: json['transactionId'] as String?,
    amount: (json['amount'] as num?)?.toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    acknowledgedAt: json['acknowledgedAt'] != null
        ? DateTime.parse(json['acknowledgedAt'] as String) : null,
    acknowledgedBy: json['acknowledgedBy'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'alertId': alertId,
    'userId': userId,
    'severity': severity.name,
    'status': status.name,
    'ruleId': ruleId,
    'ruleName': ruleName,
    'description': description,
    if (transactionId != null) 'transactionId': transactionId,
    if (amount != null) 'amount': amount,
    'createdAt': createdAt.toIso8601String(),
  };
}
