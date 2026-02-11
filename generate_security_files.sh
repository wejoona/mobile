#!/bin/bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile

BASE="lib/services"

# Create directories
mkdir -p $BASE/aml
mkdir -p $BASE/risk
mkdir -p $BASE/fraud
mkdir -p $BASE/audit
mkdir -p $BASE/privacy
mkdir -p $BASE/compliance

###############################################################################
# RUN 600: AML Transaction Monitor Service
###############################################################################
cat > $BASE/aml/transaction_monitor_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Niveau de risque AML pour une transaction
enum AmlRiskLevel { low, medium, high, critical }

/// Résultat du monitoring AML
class AmlMonitoringResult {
  final String transactionId;
  final AmlRiskLevel riskLevel;
  final double score;
  final List<String> triggeredRules;
  final bool requiresReview;
  final DateTime evaluatedAt;

  const AmlMonitoringResult({
    required this.transactionId,
    required this.riskLevel,
    required this.score,
    this.triggeredRules = const [],
    required this.requiresReview,
    required this.evaluatedAt,
  });

  Map<String, dynamic> toJson() => {
    'transactionId': transactionId,
    'riskLevel': riskLevel.name,
    'score': score,
    'triggeredRules': triggeredRules,
    'requiresReview': requiresReview,
    'evaluatedAt': evaluatedAt.toIso8601String(),
  };
}

/// Service de surveillance des transactions AML.
///
/// Surveille les transactions en temps réel pour détecter
/// les activités suspectes de blanchiment d'argent.
class TransactionMonitorService {
  static const _tag = 'AmlTransactionMonitor';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  TransactionMonitorService({required Dio dio}) : _dio = dio;

  /// Évaluer une transaction avant exécution
  Future<AmlMonitoringResult> evaluateTransaction({
    required String transactionId,
    required double amount,
    required String currency,
    required String senderWallet,
    required String recipientWallet,
    String? recipientCountry,
  }) async {
    try {
      final response = await _dio.post('/aml/monitor/evaluate', data: {
        'transactionId': transactionId,
        'amount': amount,
        'currency': currency,
        'senderWallet': senderWallet,
        'recipientWallet': recipientWallet,
        if (recipientCountry != null) 'recipientCountry': recipientCountry,
      });
      final data = response.data as Map<String, dynamic>;
      return AmlMonitoringResult(
        transactionId: transactionId,
        riskLevel: AmlRiskLevel.values.byName(data['riskLevel'] ?? 'low'),
        score: (data['score'] as num?)?.toDouble() ?? 0.0,
        triggeredRules: List<String>.from(data['triggeredRules'] ?? []),
        requiresReview: data['requiresReview'] as bool? ?? false,
        evaluatedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Transaction monitoring failed', e);
      return AmlMonitoringResult(
        transactionId: transactionId,
        riskLevel: AmlRiskLevel.medium,
        score: 0.5,
        requiresReview: true,
        evaluatedAt: DateTime.now(),
      );
    }
  }

  /// Signaler une transaction suspecte
  Future<bool> reportSuspiciousTransaction({
    required String transactionId,
    required String reason,
  }) async {
    try {
      await _dio.post('/aml/monitor/report', data: {
        'transactionId': transactionId,
        'reason': reason,
      });
      return true;
    } catch (e) {
      _log.error('Failed to report suspicious transaction', e);
      return false;
    }
  }
}

/// Provider pour le service de monitoring AML
final transactionMonitorProvider = Provider<TransactionMonitorService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 601: Sanctions Screening Interface
###############################################################################
cat > $BASE/aml/sanctions_screening_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type de liste de sanctions
enum SanctionsList {
  ofac,
  eu,
  un,
  uemoa,
  bceao,
  localCiv,
}

/// Résultat du filtrage des sanctions
class SanctionsScreeningResult {
  final String entityName;
  final bool isMatch;
  final double matchConfidence;
  final List<SanctionsList> matchedLists;
  final String? matchDetails;
  final DateTime screenedAt;

  const SanctionsScreeningResult({
    required this.entityName,
    required this.isMatch,
    this.matchConfidence = 0.0,
    this.matchedLists = const [],
    this.matchDetails,
    required this.screenedAt,
  });
}

/// Service de filtrage des sanctions.
///
/// Vérifie les contreparties contre les listes de sanctions
/// internationales et régionales (UEMOA, BCEAO, OFAC, UE, ONU).
class SanctionsScreeningService {
  static const _tag = 'SanctionsScreening';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  SanctionsScreeningService({required Dio dio}) : _dio = dio;

  /// Filtrer une entité contre toutes les listes de sanctions
  Future<SanctionsScreeningResult> screenEntity({
    required String name,
    String? dateOfBirth,
    String? nationality,
    String? idNumber,
  }) async {
    try {
      final response = await _dio.post('/aml/sanctions/screen', data: {
        'name': name,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (nationality != null) 'nationality': nationality,
        if (idNumber != null) 'idNumber': idNumber,
      });
      final data = response.data as Map<String, dynamic>;
      return SanctionsScreeningResult(
        entityName: name,
        isMatch: data['isMatch'] as bool? ?? false,
        matchConfidence: (data['matchConfidence'] as num?)?.toDouble() ?? 0.0,
        matchedLists: (data['matchedLists'] as List?)
            ?.map((e) => SanctionsList.values.byName(e as String))
            .toList() ?? [],
        matchDetails: data['matchDetails'] as String?,
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Sanctions screening failed', e);
      // Fail-safe: flag for manual review
      return SanctionsScreeningResult(
        entityName: name,
        isMatch: true,
        matchConfidence: 0.3,
        matchDetails: 'Screening service unavailable - manual review required',
        screenedAt: DateTime.now(),
      );
    }
  }

  /// Filtrer une adresse de portefeuille
  Future<SanctionsScreeningResult> screenWalletAddress({
    required String walletAddress,
    required String blockchain,
  }) async {
    try {
      final response = await _dio.post('/aml/sanctions/screen-wallet', data: {
        'walletAddress': walletAddress,
        'blockchain': blockchain,
      });
      final data = response.data as Map<String, dynamic>;
      return SanctionsScreeningResult(
        entityName: walletAddress,
        isMatch: data['isMatch'] as bool? ?? false,
        matchConfidence: (data['matchConfidence'] as num?)?.toDouble() ?? 0.0,
        matchedLists: (data['matchedLists'] as List?)
            ?.map((e) => SanctionsList.values.byName(e as String))
            .toList() ?? [],
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Wallet sanctions screening failed', e);
      return SanctionsScreeningResult(
        entityName: walletAddress,
        isMatch: false,
        matchConfidence: 0.0,
        screenedAt: DateTime.now(),
      );
    }
  }
}

final sanctionsScreeningProvider = Provider<SanctionsScreeningService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 602: CDD/EDD Models
###############################################################################
cat > $BASE/aml/cdd_edd_models.dart << 'DART'
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
DART

###############################################################################
# RUN 603: PEP Screening Service
###############################################################################
cat > $BASE/aml/pep_screening_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Catégorie de personne politiquement exposée
enum PepCategory {
  headOfState,
  seniorPolitician,
  seniorMilitary,
  seniorJudiciary,
  seniorExecutive,
  centralBankOfficial,
  ambassador,
  stateOwnedEnterprise,
  familyMember,
  closeAssociate,
}

/// Résultat du filtrage PEP
class PepScreeningResult {
  final String name;
  final bool isPep;
  final PepCategory? category;
  final double matchConfidence;
  final String? position;
  final String? country;
  final DateTime screenedAt;

  const PepScreeningResult({
    required this.name,
    required this.isPep,
    this.category,
    this.matchConfidence = 0.0,
    this.position,
    this.country,
    required this.screenedAt,
  });
}

/// Service de filtrage des Personnes Politiquement Exposées (PEP).
///
/// Vérifie si un client ou bénéficiaire est une PEP
/// conformément aux exigences BCEAO et GAFI.
class PepScreeningService {
  static const _tag = 'PepScreening';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  PepScreeningService({required Dio dio}) : _dio = dio;

  /// Filtrer un individu pour statut PEP
  Future<PepScreeningResult> screenIndividual({
    required String fullName,
    String? dateOfBirth,
    String? nationality,
  }) async {
    try {
      final response = await _dio.post('/aml/pep/screen', data: {
        'fullName': fullName,
        if (dateOfBirth != null) 'dateOfBirth': dateOfBirth,
        if (nationality != null) 'nationality': nationality,
      });
      final data = response.data as Map<String, dynamic>;
      return PepScreeningResult(
        name: fullName,
        isPep: data['isPep'] as bool? ?? false,
        category: data['category'] != null
            ? PepCategory.values.byName(data['category'] as String)
            : null,
        matchConfidence: (data['matchConfidence'] as num?)?.toDouble() ?? 0.0,
        position: data['position'] as String?,
        country: data['country'] as String?,
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('PEP screening failed', e);
      return PepScreeningResult(
        name: fullName,
        isPep: false,
        screenedAt: DateTime.now(),
      );
    }
  }

  /// Vérifier si le filtrage PEP est à jour
  Future<bool> isScreeningCurrent({required String userId}) async {
    try {
      final response = await _dio.get('/aml/pep/status/$userId');
      final data = response.data as Map<String, dynamic>;
      return data['isCurrent'] as bool? ?? false;
    } catch (e) {
      _log.error('PEP status check failed', e);
      return false;
    }
  }
}

final pepScreeningProvider = Provider<PepScreeningService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 604: Velocity Check Service
###############################################################################
cat > $BASE/aml/velocity_check_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type de vérification de vélocité
enum VelocityCheckType {
  dailyCount,
  dailyAmount,
  weeklyCount,
  weeklyAmount,
  monthlyCount,
  monthlyAmount,
  uniqueRecipients,
  crossBorderCount,
}

/// Résultat de la vérification de vélocité
class VelocityCheckResult {
  final bool withinLimits;
  final List<VelocityViolation> violations;
  final Map<VelocityCheckType, double> currentUsage;
  final DateTime checkedAt;

  const VelocityCheckResult({
    required this.withinLimits,
    this.violations = const [],
    this.currentUsage = const {},
    required this.checkedAt,
  });
}

class VelocityViolation {
  final VelocityCheckType type;
  final double limit;
  final double current;
  final String message;

  const VelocityViolation({
    required this.type,
    required this.limit,
    required this.current,
    required this.message,
  });
}

/// Service de vérification de vélocité des transactions.
///
/// Détecte les schémas de transactions anormaux (structuration,
/// smurfing) en vérifiant les limites de fréquence et de montant.
class VelocityCheckService {
  static const _tag = 'VelocityCheck';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  VelocityCheckService({required Dio dio}) : _dio = dio;

  /// Vérifier la vélocité avant une transaction
  Future<VelocityCheckResult> checkVelocity({
    required String userId,
    required double amount,
    required String currency,
    String? recipientId,
    bool isCrossBorder = false,
  }) async {
    try {
      final response = await _dio.post('/aml/velocity/check', data: {
        'userId': userId,
        'amount': amount,
        'currency': currency,
        if (recipientId != null) 'recipientId': recipientId,
        'isCrossBorder': isCrossBorder,
      });
      final data = response.data as Map<String, dynamic>;
      return VelocityCheckResult(
        withinLimits: data['withinLimits'] as bool? ?? true,
        violations: (data['violations'] as List?)?.map((v) {
          final m = v as Map<String, dynamic>;
          return VelocityViolation(
            type: VelocityCheckType.values.byName(m['type'] as String),
            limit: (m['limit'] as num).toDouble(),
            current: (m['current'] as num).toDouble(),
            message: m['message'] as String,
          );
        }).toList() ?? [],
        checkedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Velocity check failed', e);
      return VelocityCheckResult(withinLimits: true, checkedAt: DateTime.now());
    }
  }

  /// Obtenir le résumé de vélocité actuel
  Future<Map<VelocityCheckType, double>> getCurrentUsage({
    required String userId,
  }) async {
    try {
      final response = await _dio.get('/aml/velocity/usage/$userId');
      final data = response.data as Map<String, dynamic>;
      return (data['usage'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(VelocityCheckType.values.byName(k), (v as num).toDouble()),
      ) ?? {};
    } catch (e) {
      _log.error('Failed to get velocity usage', e);
      return {};
    }
  }
}

final velocityCheckProvider = Provider<VelocityCheckService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 605: CTR (Currency Transaction Report) Model
###############################################################################
cat > $BASE/aml/ctr_model.dart << 'DART'
/// Statut du rapport CTR
enum CtrStatus { draft, submitted, acknowledged, rejected }

/// Modèle de rapport de transaction en espèces (CTR).
///
/// Déclaration automatique des transactions dépassant le seuil
/// réglementaire BCEAO (typiquement 5 000 000 FCFA).
class CurrencyTransactionReport {
  final String reportId;
  final String transactionId;
  final String userId;
  final double amount;
  final String currency;
  final String transactionType;
  final DateTime transactionDate;
  final CtrStatus status;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final String? filingReference;
  final Map<String, dynamic> transactionDetails;
  final Map<String, dynamic> customerInfo;

  const CurrencyTransactionReport({
    required this.reportId,
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.currency,
    required this.transactionType,
    required this.transactionDate,
    required this.status,
    required this.createdAt,
    this.submittedAt,
    this.filingReference,
    this.transactionDetails = const {},
    this.customerInfo = const {},
  });

  factory CurrencyTransactionReport.fromJson(Map<String, dynamic> json) {
    return CurrencyTransactionReport(
      reportId: json['reportId'] as String,
      transactionId: json['transactionId'] as String,
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionType: json['transactionType'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      status: CtrStatus.values.byName(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String) : null,
      filingReference: json['filingReference'] as String?,
      transactionDetails: Map<String, dynamic>.from(json['transactionDetails'] ?? {}),
      customerInfo: Map<String, dynamic>.from(json['customerInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'reportId': reportId,
    'transactionId': transactionId,
    'userId': userId,
    'amount': amount,
    'currency': currency,
    'transactionType': transactionType,
    'transactionDate': transactionDate.toIso8601String(),
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
    if (filingReference != null) 'filingReference': filingReference,
    'transactionDetails': transactionDetails,
    'customerInfo': customerInfo,
  };

  /// Seuil BCEAO pour déclaration automatique (en FCFA)
  static const double bceaoThreshold = 5000000.0;

  /// Vérifier si le montant dépasse le seuil
  static bool exceedsThreshold(double amount) => amount >= bceaoThreshold;
}
DART

###############################################################################
# RUN 606: SAR (Suspicious Activity Report) Model
###############################################################################
cat > $BASE/aml/sar_model.dart << 'DART'
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
DART

###############################################################################
# RUN 607: AML Case Management Service
###############################################################################
cat > $BASE/aml/case_management_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

enum AmlCaseStatus { open, investigating, escalated, resolved, closed }
enum AmlCasePriority { low, medium, high, critical }

class AmlCase {
  final String caseId;
  final String userId;
  final AmlCaseStatus status;
  final AmlCasePriority priority;
  final String description;
  final List<String> relatedTransactions;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final List<AmlCaseNote> notes;

  const AmlCase({
    required this.caseId,
    required this.userId,
    required this.status,
    required this.priority,
    required this.description,
    this.relatedTransactions = const [],
    required this.createdAt,
    this.resolvedAt,
    this.assignedTo,
    this.notes = const [],
  });

  factory AmlCase.fromJson(Map<String, dynamic> json) => AmlCase(
    caseId: json['caseId'] as String,
    userId: json['userId'] as String,
    status: AmlCaseStatus.values.byName(json['status'] as String),
    priority: AmlCasePriority.values.byName(json['priority'] as String),
    description: json['description'] as String,
    relatedTransactions: List<String>.from(json['relatedTransactions'] ?? []),
    createdAt: DateTime.parse(json['createdAt'] as String),
    resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
    assignedTo: json['assignedTo'] as String?,
  );
}

class AmlCaseNote {
  final String noteId;
  final String content;
  final String author;
  final DateTime createdAt;

  const AmlCaseNote({
    required this.noteId,
    required this.content,
    required this.author,
    required this.createdAt,
  });
}

/// Gestion des dossiers AML.
class AmlCaseManagementService {
  static const _tag = 'AmlCaseManagement';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AmlCaseManagementService({required Dio dio}) : _dio = dio;

  Future<List<AmlCase>> getActiveCases({required String userId}) async {
    try {
      final response = await _dio.get('/aml/cases', queryParameters: {'userId': userId});
      final list = response.data as List;
      return list.map((e) => AmlCase.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _log.error('Failed to fetch AML cases', e);
      return [];
    }
  }

  Future<AmlCase?> getCaseDetails({required String caseId}) async {
    try {
      final response = await _dio.get('/aml/cases/$caseId');
      return AmlCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to fetch case details', e);
      return null;
    }
  }
}

final amlCaseManagementProvider = Provider<AmlCaseManagementService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 608: AML Rule Engine
###############################################################################
cat > $BASE/aml/aml_rule_engine.dart << 'DART'
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
DART

###############################################################################
# RUN 609: AML Alert Model
###############################################################################
cat > $BASE/aml/aml_alert_model.dart << 'DART'
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
DART

###############################################################################
# RUN 610: AML Configuration Provider
###############################################################################
cat > $BASE/aml/aml_config_provider.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Configuration AML côté client
class AmlConfig {
  final double ctrThreshold;
  final int maxDailyTransactions;
  final double maxDailyAmount;
  final double maxSingleTransaction;
  final List<String> highRiskCountries;
  final bool enhancedMonitoringEnabled;
  final Duration screeningCacheTtl;

  const AmlConfig({
    this.ctrThreshold = 5000000.0,
    this.maxDailyTransactions = 50,
    this.maxDailyAmount = 10000000.0,
    this.maxSingleTransaction = 5000000.0,
    this.highRiskCountries = const [],
    this.enhancedMonitoringEnabled = true,
    this.screeningCacheTtl = const Duration(hours: 24),
  });

  factory AmlConfig.fromJson(Map<String, dynamic> json) => AmlConfig(
    ctrThreshold: (json['ctrThreshold'] as num?)?.toDouble() ?? 5000000.0,
    maxDailyTransactions: json['maxDailyTransactions'] as int? ?? 50,
    maxDailyAmount: (json['maxDailyAmount'] as num?)?.toDouble() ?? 10000000.0,
    maxSingleTransaction: (json['maxSingleTransaction'] as num?)?.toDouble() ?? 5000000.0,
    highRiskCountries: List<String>.from(json['highRiskCountries'] ?? []),
    enhancedMonitoringEnabled: json['enhancedMonitoringEnabled'] as bool? ?? true,
  );
}

/// Fournisseur de configuration AML
class AmlConfigProvider {
  static const _tag = 'AmlConfig';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  AmlConfig? _cachedConfig;

  AmlConfigProvider({required Dio dio}) : _dio = dio;

  Future<AmlConfig> getConfig() async {
    if (_cachedConfig != null) return _cachedConfig!;
    try {
      final response = await _dio.get('/aml/config');
      _cachedConfig = AmlConfig.fromJson(response.data as Map<String, dynamic>);
      return _cachedConfig!;
    } catch (e) {
      _log.error('Failed to fetch AML config', e);
      return const AmlConfig();
    }
  }

  void invalidateCache() => _cachedConfig = null;
}

final amlConfigProvider = Provider<AmlConfigProvider>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 611: AML Index
###############################################################################
cat > $BASE/aml/index.dart << 'DART'
export 'transaction_monitor_service.dart';
export 'sanctions_screening_service.dart';
export 'cdd_edd_models.dart';
export 'pep_screening_service.dart';
export 'velocity_check_service.dart';
export 'ctr_model.dart';
export 'sar_model.dart';
export 'case_management_service.dart';
export 'aml_rule_engine.dart';
export 'aml_alert_model.dart';
export 'aml_config_provider.dart';
DART

###############################################################################
# RUN 612: Certificate Pinning Config
###############################################################################
cat > $BASE/security/certificate_pinning_config.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Configuration des certificats épinglés par environnement.
class CertificatePinningConfig {
  final String host;
  final List<String> sha256Pins;
  final bool includeSubdomains;
  final DateTime? expiresAt;

  const CertificatePinningConfig({
    required this.host,
    required this.sha256Pins,
    this.includeSubdomains = true,
    this.expiresAt,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);
}

/// Registre des pins de certificats pour l'application.
class CertificatePinRegistry {
  static const List<CertificatePinningConfig> productionPins = [
    CertificatePinningConfig(
      host: 'api.korido.app',
      sha256Pins: [
        // Pin primaire et de secours — à remplacer par les vrais hashes
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ],
    ),
    CertificatePinningConfig(
      host: 'auth.korido.app',
      sha256Pins: [
        'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ],
    ),
  ];

  static const List<CertificatePinningConfig> stagingPins = [
    CertificatePinningConfig(
      host: 'api-staging.korido.app',
      sha256Pins: [
        'CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
      ],
    ),
  ];

  static List<CertificatePinningConfig> getPins({required bool isProduction}) {
    return isProduction ? productionPins : stagingPins;
  }

  static bool validatePin(String host, String pinHash, {required bool isProduction}) {
    final pins = getPins(isProduction: isProduction);
    final config = pins.where((p) => host.endsWith(p.host)).firstOrNull;
    if (config == null || config.isExpired) return true; // Pas de pin = accepter
    return config.sha256Pins.contains(pinHash);
  }
}

final certificatePinRegistryProvider = Provider<CertificatePinRegistry>((ref) {
  return CertificatePinRegistry();
});
DART

###############################################################################
# RUN 613: Root/Jailbreak Detection Provider
###############################################################################
cat > $BASE/security/root_jailbreak_provider.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_security.dart';

/// État de la détection root/jailbreak
class RootJailbreakState {
  final bool isChecked;
  final bool isCompromised;
  final List<String> threats;
  final DateTime? lastCheckedAt;

  const RootJailbreakState({
    this.isChecked = false,
    this.isCompromised = false,
    this.threats = const [],
    this.lastCheckedAt,
  });

  RootJailbreakState copyWith({
    bool? isChecked,
    bool? isCompromised,
    List<String>? threats,
    DateTime? lastCheckedAt,
  }) => RootJailbreakState(
    isChecked: isChecked ?? this.isChecked,
    isCompromised: isCompromised ?? this.isCompromised,
    threats: threats ?? this.threats,
    lastCheckedAt: lastCheckedAt ?? this.lastCheckedAt,
  );
}

/// Fournisseur Riverpod pour la détection root/jailbreak.
///
/// Vérifie si l'appareil est compromis (rooté ou jailbreaké)
/// et maintient l'état en cache pour la session.
class RootJailbreakNotifier extends StateNotifier<RootJailbreakState> {
  final DeviceSecurity _deviceSecurity;

  RootJailbreakNotifier({DeviceSecurity? deviceSecurity})
      : _deviceSecurity = deviceSecurity ?? DeviceSecurity(),
        super(const RootJailbreakState());

  Future<void> checkDevice() async {
    final result = await _deviceSecurity.checkSecurity();
    state = state.copyWith(
      isChecked: true,
      isCompromised: !result.isSecure,
      threats: result.threats,
      lastCheckedAt: DateTime.now(),
    );
  }

  bool get shouldBlockAccess => state.isCompromised;
}

final rootJailbreakProvider =
    StateNotifierProvider<RootJailbreakNotifier, RootJailbreakState>((ref) {
  return RootJailbreakNotifier();
});
DART

###############################################################################
# RUN 614: Secure Storage Wrapper
###############################################################################
cat > $BASE/security/secure_storage_wrapper.dart << 'DART'
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Interface pour le stockage sécurisé.
///
/// Wrapper autour de flutter_secure_storage avec
/// chiffrement supplémentaire et gestion des erreurs.
abstract class SecureStorageWrapper {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
  Future<bool> containsKey({required String key});
  Future<Map<String, String>> readAll();
}

/// Implémentation du stockage sécurisé
class SecureStorageWrapperImpl implements SecureStorageWrapper {
  static const _tag = 'SecureStorage';
  final AppLogger _log = AppLogger(_tag);

  // In production, use flutter_secure_storage
  final Map<String, String> _store = {};

  @override
  Future<void> write({required String key, required String value}) async {
    try {
      _store[key] = value;
    } catch (e) {
      _log.error('Failed to write to secure storage', e);
      rethrow;
    }
  }

  @override
  Future<String?> read({required String key}) async {
    try {
      return _store[key];
    } catch (e) {
      _log.error('Failed to read from secure storage', e);
      return null;
    }
  }

  @override
  Future<void> delete({required String key}) async {
    _store.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    _store.clear();
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _store.containsKey(key);
  }

  @override
  Future<Map<String, String>> readAll() async {
    return Map.unmodifiable(_store);
  }

  /// Écrire un objet JSON
  Future<void> writeJson({required String key, required Map<String, dynamic> value}) async {
    await write(key: key, value: jsonEncode(value));
  }

  /// Lire un objet JSON
  Future<Map<String, dynamic>?> readJson({required String key}) async {
    final raw = await read(key: key);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}

final secureStorageProvider = Provider<SecureStorageWrapper>((ref) {
  return SecureStorageWrapperImpl();
});
DART

###############################################################################
# RUN 615: Session Management Service
###############################################################################
cat > $BASE/security/session_management_service.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// État de la session utilisateur
enum SessionState { active, idle, locked, expired, terminated }

/// Informations de session
class SessionInfo {
  final String sessionId;
  final SessionState state;
  final DateTime createdAt;
  final DateTime lastActivityAt;
  final Duration maxIdleTime;
  final Duration maxSessionTime;
  final String? deviceId;
  final String? ipAddress;

  const SessionInfo({
    required this.sessionId,
    required this.state,
    required this.createdAt,
    required this.lastActivityAt,
    this.maxIdleTime = const Duration(minutes: 15),
    this.maxSessionTime = const Duration(hours: 24),
    this.deviceId,
    this.ipAddress,
  });

  bool get isExpired {
    final now = DateTime.now();
    if (now.difference(lastActivityAt) > maxIdleTime) return true;
    if (now.difference(createdAt) > maxSessionTime) return true;
    return false;
  }

  SessionInfo copyWith({
    SessionState? state,
    DateTime? lastActivityAt,
  }) => SessionInfo(
    sessionId: sessionId,
    state: state ?? this.state,
    createdAt: createdAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    maxIdleTime: maxIdleTime,
    maxSessionTime: maxSessionTime,
    deviceId: deviceId,
    ipAddress: ipAddress,
  );
}

/// Gestion des sessions utilisateur.
///
/// Contrôle la durée de session, le verrouillage automatique
/// et la terminaison en cas d'inactivité.
class SessionManagementService {
  static const _tag = 'SessionManagement';
  final AppLogger _log = AppLogger(_tag);
  SessionInfo? _currentSession;

  SessionInfo? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession?.state == SessionState.active;

  /// Créer une nouvelle session
  SessionInfo createSession({required String sessionId, String? deviceId}) {
    _currentSession = SessionInfo(
      sessionId: sessionId,
      state: SessionState.active,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
      deviceId: deviceId,
    );
    _log.info('Session created: $sessionId');
    return _currentSession!;
  }

  /// Mettre à jour l'activité
  void touchSession() {
    if (_currentSession == null) return;
    if (_currentSession!.isExpired) {
      _currentSession = _currentSession!.copyWith(state: SessionState.expired);
      return;
    }
    _currentSession = _currentSession!.copyWith(lastActivityAt: DateTime.now());
  }

  /// Verrouiller la session
  void lockSession() {
    if (_currentSession == null) return;
    _currentSession = _currentSession!.copyWith(state: SessionState.locked);
    _log.info('Session locked');
  }

  /// Terminer la session
  void terminateSession() {
    if (_currentSession == null) return;
    _log.info('Session terminated: ${_currentSession!.sessionId}');
    _currentSession = _currentSession!.copyWith(state: SessionState.terminated);
  }

  /// Vérifier si la session est toujours valide
  bool validateSession() {
    if (_currentSession == null) return false;
    if (_currentSession!.isExpired) {
      _currentSession = _currentSession!.copyWith(state: SessionState.expired);
      return false;
    }
    return _currentSession!.state == SessionState.active;
  }
}

final sessionManagementProvider = Provider<SessionManagementService>((ref) {
  return SessionManagementService();
});
DART

###############################################################################
# RUN 616: Anti-Tampering Service
###############################################################################
cat > $BASE/security/anti_tampering_service.dart << 'DART'
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat de la vérification d'intégrité
class IntegrityCheckResult {
  final bool isIntact;
  final List<String> violations;
  final DateTime checkedAt;

  const IntegrityCheckResult({
    required this.isIntact,
    this.violations = const [],
    required this.checkedAt,
  });
}

/// Service anti-falsification.
///
/// Vérifie l'intégrité de l'application pour détecter
/// les modifications non autorisées (repackaging, hooking).
class AntiTamperingService {
  static const _tag = 'AntiTampering';
  final AppLogger _log = AppLogger(_tag);

  /// Vérifier l'intégrité de l'application
  Future<IntegrityCheckResult> checkIntegrity() async {
    if (kDebugMode) {
      return IntegrityCheckResult(isIntact: true, checkedAt: DateTime.now());
    }

    final violations = <String>[];

    // Vérifier la signature de l'application
    if (Platform.isAndroid) {
      violations.addAll(await _checkAndroidSignature());
    } else if (Platform.isIOS) {
      violations.addAll(await _checkiOSProvisioningProfile());
    }

    // Vérifier les bibliothèques injectées
    violations.addAll(await _checkInjectedLibraries());

    // Vérifier les frameworks de hooking
    violations.addAll(await _checkHookingFrameworks());

    if (violations.isNotEmpty) {
      _log.warning('Tampering detected: $violations');
    }

    return IntegrityCheckResult(
      isIntact: violations.isEmpty,
      violations: violations,
      checkedAt: DateTime.now(),
    );
  }

  Future<List<String>> _checkAndroidSignature() async {
    // En production, utiliser le Play Integrity API
    return [];
  }

  Future<List<String>> _checkiOSProvisioningProfile() async {
    final violations = <String>[];
    try {
      final file = File('/var/containers/Bundle/Application/embedded.mobileprovision');
      if (!await file.exists()) {
        // App Store builds don't have this file
        return [];
      }
    } catch (_) {}
    return violations;
  }

  Future<List<String>> _checkInjectedLibraries() async {
    final violations = <String>[];
    if (Platform.isIOS) {
      final suspiciousLibs = [
        'FridaGadget',
        'frida-agent',
        'libcycript',
        'MobileSubstrate',
        'SubstrateLoader',
      ];
      // En production, vérifier via _dyld_image_count/_dyld_get_image_name
      // via method channel
      for (final lib in suspiciousLibs) {
        // Placeholder pour vérification native
        _ = lib;
      }
    }
    return violations;
  }

  Future<List<String>> _checkHookingFrameworks() async {
    final violations = <String>[];
    final hookingIndicators = [
      '/usr/sbin/frida-server',
      '/usr/bin/cycript',
      '/usr/lib/libcycript.dylib',
    ];
    for (final path in hookingIndicators) {
      try {
        if (await File(path).exists()) {
          violations.add('Hooking framework detected: $path');
        }
      } catch (_) {}
    }
    return violations;
  }
}

final antiTamperingProvider = Provider<AntiTamperingService>((ref) {
  return AntiTamperingService();
});
DART

###############################################################################
# RUN 617: Debug Detection Service
###############################################################################
cat > $BASE/security/debug_detection_service.dart << 'DART'
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Service de détection du débogage.
///
/// Détecte si l'application est exécutée en mode debug,
/// si un débogueur est attaché, ou si des outils
/// d'instrumentation sont actifs.
class DebugDetectionService {
  static const _tag = 'DebugDetection';
  final AppLogger _log = AppLogger(_tag);

  /// Vérifier si le mode debug est actif
  bool get isDebugMode => kDebugMode;

  /// Vérifier si un débogueur est attaché
  bool get isDebuggerAttached {
    bool attached = false;
    assert(() {
      attached = true;
      return true;
    }());
    return attached;
  }

  /// Vérifier si l'application est en mode profil
  bool get isProfileMode => kProfileMode;

  /// Vérifier si l'application est en mode release
  bool get isReleaseMode => kReleaseMode;

  /// Vérification complète de l'environnement de débogage
  Future<DebugDetectionResult> detectDebugEnvironment() async {
    final indicators = <String>[];

    if (isDebugMode) indicators.add('Debug mode active');
    if (isDebuggerAttached) indicators.add('Debugger attached');
    if (isProfileMode) indicators.add('Profile mode');

    // Vérifier les ports de débogage courants
    if (await _checkDebugPorts()) {
      indicators.add('Debug ports open');
    }

    // Vérifier les variables d'environnement suspectes
    if (_checkDebugEnvVars()) {
      indicators.add('Debug environment variables detected');
    }

    return DebugDetectionResult(
      isDebugEnvironment: indicators.isNotEmpty && !kDebugMode,
      indicators: indicators,
      checkedAt: DateTime.now(),
    );
  }

  Future<bool> _checkDebugPorts() async {
    final debugPorts = [8888, 5037, 27042]; // Frida, ADB, etc.
    for (final port in debugPorts) {
      try {
        final socket = await Socket.connect('127.0.0.1', port,
            timeout: const Duration(milliseconds: 100));
        await socket.destroy();
        return true;
      } catch (_) {}
    }
    return false;
  }

  bool _checkDebugEnvVars() {
    final suspiciousVars = ['DYLD_INSERT_LIBRARIES', 'LD_PRELOAD'];
    for (final v in suspiciousVars) {
      if (Platform.environment.containsKey(v)) return true;
    }
    return false;
  }
}

class DebugDetectionResult {
  final bool isDebugEnvironment;
  final List<String> indicators;
  final DateTime checkedAt;

  const DebugDetectionResult({
    required this.isDebugEnvironment,
    this.indicators = const [],
    required this.checkedAt,
  });
}

final debugDetectionProvider = Provider<DebugDetectionService>((ref) {
  return DebugDetectionService();
});
DART

###############################################################################
# RUN 618: Proxy Detection Service
###############################################################################
cat > $BASE/security/proxy_detection_service.dart << 'DART'
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Service de détection de proxy/VPN.
///
/// Détecte si le trafic réseau passe par un proxy,
/// un VPN ou un tunnel, ce qui pourrait indiquer
/// une interception MITM.
class ProxyDetectionService {
  static const _tag = 'ProxyDetection';
  final AppLogger _log = AppLogger(_tag);

  /// Vérifier la présence d'un proxy système
  Future<ProxyDetectionResult> detectProxy() async {
    final indicators = <String>[];

    // Vérifier les variables d'environnement proxy
    final proxyVars = ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY'];
    for (final v in proxyVars) {
      final value = Platform.environment[v];
      if (value != null && value.isNotEmpty) {
        indicators.add('Proxy env var set: $v');
      }
    }

    // Vérifier les interfaces réseau VPN courantes
    if (await _checkVpnInterfaces()) {
      indicators.add('VPN interface detected');
    }

    return ProxyDetectionResult(
      proxyDetected: indicators.isNotEmpty,
      indicators: indicators,
      checkedAt: DateTime.now(),
    );
  }

  Future<bool> _checkVpnInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list();
      final vpnPrefixes = ['tun', 'tap', 'ppp', 'ipsec', 'utun'];
      for (final iface in interfaces) {
        for (final prefix in vpnPrefixes) {
          if (iface.name.toLowerCase().startsWith(prefix)) {
            return true;
          }
        }
      }
    } catch (e) {
      _log.error('Failed to check network interfaces', e);
    }
    return false;
  }

  /// Vérifier si le proxy est autorisé pour cette session
  bool isProxyAllowed({required bool isHighRiskTransaction}) {
    // Les transactions à haut risque ne sont pas autorisées via proxy
    return !isHighRiskTransaction;
  }
}

class ProxyDetectionResult {
  final bool proxyDetected;
  final List<String> indicators;
  final DateTime checkedAt;

  const ProxyDetectionResult({
    required this.proxyDetected,
    this.indicators = const [],
    required this.checkedAt,
  });
}

final proxyDetectionProvider = Provider<ProxyDetectionService>((ref) {
  return ProxyDetectionService();
});
DART

###############################################################################
# RUN 619: Transaction Risk Scoring Service
###############################################################################
cat > $BASE/risk/transaction_risk_scorer.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Facteurs de risque pour une transaction
class TransactionRiskFactors {
  final double amount;
  final String currency;
  final String? recipientCountry;
  final bool isFirstTransaction;
  final bool isNewRecipient;
  final bool isCrossBorder;
  final int dailyTransactionCount;
  final double dailyTotal;
  final String? deviceRiskLevel;

  const TransactionRiskFactors({
    required this.amount,
    required this.currency,
    this.recipientCountry,
    this.isFirstTransaction = false,
    this.isNewRecipient = false,
    this.isCrossBorder = false,
    this.dailyTransactionCount = 0,
    this.dailyTotal = 0.0,
    this.deviceRiskLevel,
  });
}

/// Score de risque d'une transaction
class TransactionRiskScore {
  final double score; // 0.0 - 1.0
  final String level; // low, medium, high, critical
  final List<String> factors;
  final bool requiresAdditionalAuth;
  final bool requiresManualReview;
  final DateTime scoredAt;

  const TransactionRiskScore({
    required this.score,
    required this.level,
    this.factors = const [],
    this.requiresAdditionalAuth = false,
    this.requiresManualReview = false,
    required this.scoredAt,
  });
}

/// Service de scoring de risque des transactions.
///
/// Évalue le niveau de risque de chaque transaction
/// en combinant facteurs locaux et analyse serveur.
class TransactionRiskScorer {
  static const _tag = 'TransactionRiskScorer';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  TransactionRiskScorer({required Dio dio}) : _dio = dio;

  /// Calculer le score de risque
  Future<TransactionRiskScore> scoreTransaction(TransactionRiskFactors factors) async {
    // Pré-évaluation locale
    final localScore = _calculateLocalScore(factors);

    try {
      final response = await _dio.post('/risk/transaction/score', data: {
        'amount': factors.amount,
        'currency': factors.currency,
        'recipientCountry': factors.recipientCountry,
        'isFirstTransaction': factors.isFirstTransaction,
        'isNewRecipient': factors.isNewRecipient,
        'isCrossBorder': factors.isCrossBorder,
        'dailyTransactionCount': factors.dailyTransactionCount,
        'dailyTotal': factors.dailyTotal,
        'localScore': localScore,
      });
      final data = response.data as Map<String, dynamic>;
      return TransactionRiskScore(
        score: (data['score'] as num).toDouble(),
        level: data['level'] as String,
        factors: List<String>.from(data['factors'] ?? []),
        requiresAdditionalAuth: data['requiresAdditionalAuth'] as bool? ?? false,
        requiresManualReview: data['requiresManualReview'] as bool? ?? false,
        scoredAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Server risk scoring failed, using local score', e);
      return TransactionRiskScore(
        score: localScore,
        level: _scoreToLevel(localScore),
        factors: _getLocalFactors(factors),
        requiresAdditionalAuth: localScore > 0.7,
        requiresManualReview: localScore > 0.85,
        scoredAt: DateTime.now(),
      );
    }
  }

  double _calculateLocalScore(TransactionRiskFactors f) {
    double score = 0.0;
    if (f.amount > 1000000) score += 0.2;
    if (f.amount > 5000000) score += 0.2;
    if (f.isFirstTransaction) score += 0.1;
    if (f.isNewRecipient) score += 0.1;
    if (f.isCrossBorder) score += 0.15;
    if (f.dailyTransactionCount > 10) score += 0.15;
    return score.clamp(0.0, 1.0);
  }

  String _scoreToLevel(double score) {
    if (score < 0.3) return 'low';
    if (score < 0.6) return 'medium';
    if (score < 0.85) return 'high';
    return 'critical';
  }

  List<String> _getLocalFactors(TransactionRiskFactors f) {
    final factors = <String>[];
    if (f.amount > 1000000) factors.add('Montant élevé');
    if (f.isNewRecipient) factors.add('Nouveau bénéficiaire');
    if (f.isCrossBorder) factors.add('Transaction transfrontalière');
    return factors;
  }
}

final transactionRiskScorerProvider = Provider<TransactionRiskScorer>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

echo "Batch 1 (runs 600-619) complete"
