/// Décision de risque - sealed class pour un traitement exhaustif.
sealed class RiskDecision {
  const RiskDecision();
}

/// Approuvé - la transaction peut continuer.
class RiskApproved extends RiskDecision {
  final double score;
  const RiskApproved({required this.score});
}

/// Nécessite une vérification supplémentaire.
class RiskReviewRequired extends RiskDecision {
  final double score;
  final List<String> requiredChecks;
  final String reason;
  const RiskReviewRequired({
    required this.score,
    required this.requiredChecks,
    required this.reason,
  });
}

/// Refusé - la transaction est bloquée.
class RiskDenied extends RiskDecision {
  final double score;
  final String reason;
  final bool canAppeal;
  const RiskDenied({
    required this.score,
    required this.reason,
    this.canAppeal = true,
  });
}

/// Escalation manuelle requise.
class RiskEscalated extends RiskDecision {
  final double score;
  final String escalationReason;
  final String assignedTeam;
  const RiskEscalated({
    required this.score,
    required this.escalationReason,
    this.assignedTeam = 'compliance',
  });
}

/// Pending - en attente de données supplémentaires.
class RiskPending extends RiskDecision {
  final List<String> missingData;
  const RiskPending({required this.missingData});
}
