/// Niveau de diligence requise
enum DiligenceLevel { simplified, standard, enhanced }

/// Statut de la vérification CDD
enum CddStatus { pending, inProgress, completed, expired, rejected }

/// Modèle CDD (Customer Due Diligence) — Connaissance du client
class CustomerDueDiligence {
  final String userId;
  final DiligenceLevel level;
  final CddStatus status;
  final DateTime initiatedAt;
  final DateTime? completedAt;
  final DateTime? expiresAt;
  final String? riskRating;
  final Map<String, bool> verifiedDocuments;
  final String? sourceOfFunds;
  final String? occupation;
  final double? estimatedMonthlyVolume;

  const CustomerDueDiligence({
    required this.userId,
    required this.level,
    required this.status,
    required this.initiatedAt,
    this.completedAt,
    this.expiresAt,
    this.riskRating,
    this.verifiedDocuments = const {},
    this.sourceOfFunds,
    this.occupation,
    this.estimatedMonthlyVolume,
  });

  factory CustomerDueDiligence.fromJson(Map<String, dynamic> json) {
    return CustomerDueDiligence(
      userId: json['userId'] as String,
      level: DiligenceLevel.values.byName(json['level'] as String),
      status: CddStatus.values.byName(json['status'] as String),
      initiatedAt: DateTime.parse(json['initiatedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String) : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String) : null,
      riskRating: json['riskRating'] as String?,
      verifiedDocuments: Map<String, bool>.from(json['verifiedDocuments'] ?? {}),
      sourceOfFunds: json['sourceOfFunds'] as String?,
      occupation: json['occupation'] as String?,
      estimatedMonthlyVolume: (json['estimatedMonthlyVolume'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'level': level.name,
    'status': status.name,
    'initiatedAt': initiatedAt.toIso8601String(),
    if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
    if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
    if (riskRating != null) 'riskRating': riskRating,
    'verifiedDocuments': verifiedDocuments,
    if (sourceOfFunds != null) 'sourceOfFunds': sourceOfFunds,
    if (occupation != null) 'occupation': occupation,
    if (estimatedMonthlyVolume != null) 'estimatedMonthlyVolume': estimatedMonthlyVolume,
  };

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
  bool get needsRenewal => isExpired || status == CddStatus.expired;
}

/// Modèle EDD (Enhanced Due Diligence) — Diligence renforcée
class EnhancedDueDiligence extends CustomerDueDiligence {
  final String? sourceOfWealth;
  final List<String> adverseMediaFindings;
  final bool pepScreeningDone;
  final bool sanctionsScreeningDone;
  final String? riskJustification;
  final String? seniorManagementApproval;
  final List<String> additionalDocuments;

  const EnhancedDueDiligence({
    required super.userId,
    required super.status,
    required super.initiatedAt,
    super.completedAt,
    super.expiresAt,
    super.riskRating,
    super.verifiedDocuments,
    super.sourceOfFunds,
    super.occupation,
    super.estimatedMonthlyVolume,
    this.sourceOfWealth,
    this.adverseMediaFindings = const [],
    this.pepScreeningDone = false,
    this.sanctionsScreeningDone = false,
    this.riskJustification,
    this.seniorManagementApproval,
    this.additionalDocuments = const [],
  }) : super(level: DiligenceLevel.enhanced);
}
