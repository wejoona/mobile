/// Statut de conformité d'un utilisateur ou d'une transaction.
class ComplianceStatus {
  final String userId;
  final bool isCompliant;
  final String kycTier; // basic, verified, enhanced
  final bool amlCleared;
  final bool sanctionsCleared;
  final bool pepScreened;
  final DateTime? lastReviewDate;
  final DateTime? nextReviewDate;
  final List<String> pendingActions;
  final Map<String, dynamic> details;

  const ComplianceStatus({
    required this.userId,
    required this.isCompliant,
    required this.kycTier,
    this.amlCleared = false,
    this.sanctionsCleared = false,
    this.pepScreened = false,
    this.lastReviewDate,
    this.nextReviewDate,
    this.pendingActions = const [],
    this.details = const {},
  });

  bool get needsReview =>
      nextReviewDate != null && DateTime.now().isAfter(nextReviewDate!);

  ComplianceStatus copyWith({
    bool? isCompliant,
    String? kycTier,
    bool? amlCleared,
    List<String>? pendingActions,
  }) {
    return ComplianceStatus(
      userId: userId,
      isCompliant: isCompliant ?? this.isCompliant,
      kycTier: kycTier ?? this.kycTier,
      amlCleared: amlCleared ?? this.amlCleared,
      sanctionsCleared: sanctionsCleared,
      pepScreened: pepScreened,
      lastReviewDate: lastReviewDate,
      nextReviewDate: nextReviewDate,
      pendingActions: pendingActions ?? this.pendingActions,
      details: details,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId, 'isCompliant': isCompliant, 'kycTier': kycTier,
    'amlCleared': amlCleared, 'sanctionsCleared': sanctionsCleared,
    'pepScreened': pepScreened,
  };

  factory ComplianceStatus.fromJson(Map<String, dynamic> json) {
    return ComplianceStatus(
      userId: json['userId'] as String,
      isCompliant: json['isCompliant'] as bool,
      kycTier: json['kycTier'] as String,
      amlCleared: json['amlCleared'] as bool? ?? false,
      sanctionsCleared: json['sanctionsCleared'] as bool? ?? false,
      pepScreened: json['pepScreened'] as bool? ?? false,
    );
  }
}
