/// Statut du dossier de fraude
enum FraudCaseStatus { open, investigating, confirmed, falsePositive, closed }

/// Type de fraude
enum FraudType {
  accountTakeover,
  identityTheft,
  transactionFraud,
  cardFraud,
  socialEngineering,
  phishing,
  simSwap,
  other,
}

/// Modèle de dossier de fraude
class FraudCase {
  final String caseId;
  final String userId;
  final FraudCaseStatus status;
  final FraudType fraudType;
  final String description;
  final double totalLoss;
  final String currency;
  final List<String> relatedTransactions;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final String? resolution;

  const FraudCase({
    required this.caseId,
    required this.userId,
    required this.status,
    required this.fraudType,
    required this.description,
    this.totalLoss = 0.0,
    required this.currency,
    this.relatedTransactions = const [],
    required this.reportedAt,
    this.resolvedAt,
    this.resolution,
  });

  factory FraudCase.fromJson(Map<String, dynamic> json) => FraudCase(
    caseId: json['caseId'] as String,
    userId: json['userId'] as String,
    status: FraudCaseStatus.values.byName(json['status'] as String),
    fraudType: FraudType.values.byName(json['fraudType'] as String),
    description: json['description'] as String,
    totalLoss: (json['totalLoss'] as num?)?.toDouble() ?? 0.0,
    currency: json['currency'] as String,
    relatedTransactions: List<String>.from(json['relatedTransactions'] ?? []),
    reportedAt: DateTime.parse(json['reportedAt'] as String),
    resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
    resolution: json['resolution'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'caseId': caseId,
    'userId': userId,
    'status': status.name,
    'fraudType': fraudType.name,
    'description': description,
    'totalLoss': totalLoss,
    'currency': currency,
    'relatedTransactions': relatedTransactions,
    'reportedAt': reportedAt.toIso8601String(),
    if (resolvedAt != null) 'resolvedAt': resolvedAt!.toIso8601String(),
    if (resolution != null) 'resolution': resolution,
  };
}
