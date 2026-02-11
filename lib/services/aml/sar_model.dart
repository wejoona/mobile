/// Statut du rapport SAR
enum SarStatus { draft, pendingReview, approved, submitted, acknowledged }

/// Priorité du rapport SAR
enum SarPriority { low, medium, high, critical }

/// Type d'activité suspecte
enum SuspiciousActivityType {
  structuring,
  unusualPattern,
  rapidMovement,
  sanctionsRelated,
  identityFraud,
  thirdPartyFunding,
  unusualGeography,
  layering,
  smurfing,
  other,
}

/// Modèle de déclaration de soupçon (SAR/DOS).
///
/// Déclaration de soupçon conforme aux exigences de la CENTIF
/// (Cellule Nationale de Traitement des Informations Financières)
/// de Côte d'Ivoire.
class SuspiciousActivityReport {
  final String reportId;
  final String userId;
  final SarStatus status;
  final SarPriority priority;
  final SuspiciousActivityType activityType;
  final String narrative;
  final List<String> relatedTransactionIds;
  final double totalAmountInvolved;
  final String currency;
  final DateTime activityStartDate;
  final DateTime? activityEndDate;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final String? centifReference;
  final String? reviewedBy;
  final Map<String, dynamic> subjectInfo;
  final List<String> supportingEvidence;

  const SuspiciousActivityReport({
    required this.reportId,
    required this.userId,
    required this.status,
    required this.priority,
    required this.activityType,
    required this.narrative,
    this.relatedTransactionIds = const [],
    required this.totalAmountInvolved,
    required this.currency,
    required this.activityStartDate,
    this.activityEndDate,
    required this.createdAt,
    this.submittedAt,
    this.centifReference,
    this.reviewedBy,
    this.subjectInfo = const {},
    this.supportingEvidence = const [],
  });

  factory SuspiciousActivityReport.fromJson(Map<String, dynamic> json) {
    return SuspiciousActivityReport(
      reportId: json['reportId'] as String,
      userId: json['userId'] as String,
      status: SarStatus.values.byName(json['status'] as String),
      priority: SarPriority.values.byName(json['priority'] as String),
      activityType: SuspiciousActivityType.values.byName(json['activityType'] as String),
      narrative: json['narrative'] as String,
      relatedTransactionIds: List<String>.from(json['relatedTransactionIds'] ?? []),
      totalAmountInvolved: (json['totalAmountInvolved'] as num).toDouble(),
      currency: json['currency'] as String,
      activityStartDate: DateTime.parse(json['activityStartDate'] as String),
      activityEndDate: json['activityEndDate'] != null
          ? DateTime.parse(json['activityEndDate'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String) : null,
      centifReference: json['centifReference'] as String?,
      reviewedBy: json['reviewedBy'] as String?,
      subjectInfo: Map<String, dynamic>.from(json['subjectInfo'] ?? {}),
      supportingEvidence: List<String>.from(json['supportingEvidence'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'reportId': reportId,
    'userId': userId,
    'status': status.name,
    'priority': priority.name,
    'activityType': activityType.name,
    'narrative': narrative,
    'relatedTransactionIds': relatedTransactionIds,
    'totalAmountInvolved': totalAmountInvolved,
    'currency': currency,
    'activityStartDate': activityStartDate.toIso8601String(),
    if (activityEndDate != null) 'activityEndDate': activityEndDate!.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
    if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
    if (centifReference != null) 'centifReference': centifReference,
    if (reviewedBy != null) 'reviewedBy': reviewedBy,
    'subjectInfo': subjectInfo,
    'supportingEvidence': supportingEvidence,
  };
}
