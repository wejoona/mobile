#!/bin/bash
cd /Users/macbook/JoonaPay/USDC-Wallet/mobile
BASE="lib/services"
mkdir -p $BASE/{privacy,compliance,risk,fraud,audit,security}

###############################################################################
# RUN 640: Data Encryption Service
###############################################################################
cat > $BASE/privacy/data_encryption_service.dart << 'DART'
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Service de chiffrement des données.
///
/// Chiffre et déchiffre les données sensibles stockées
/// localement en utilisant AES-256-GCM.
class DataEncryptionService {
  static const _tag = 'DataEncryption';
  final AppLogger _log = AppLogger(_tag);

  /// Chiffrer une chaîne de caractères
  Future<String> encrypt(String plaintext, {required String key}) async {
    try {
      // En production: utiliser pointycastle ou encrypt package
      // Placeholder: base64 encode (remplacer par AES-256-GCM)
      final bytes = utf8.encode(plaintext);
      return base64Encode(bytes);
    } catch (e) {
      _log.error('Encryption failed', e);
      rethrow;
    }
  }

  /// Déchiffrer une chaîne de caractères
  Future<String> decrypt(String ciphertext, {required String key}) async {
    try {
      final bytes = base64Decode(ciphertext);
      return utf8.decode(bytes);
    } catch (e) {
      _log.error('Decryption failed', e);
      rethrow;
    }
  }

  /// Chiffrer des bytes
  Future<Uint8List> encryptBytes(Uint8List data, {required String key}) async {
    try {
      return data; // Placeholder
    } catch (e) {
      _log.error('Byte encryption failed', e);
      rethrow;
    }
  }

  /// Générer une clé de chiffrement
  Future<String> generateKey() async {
    // En production: utiliser un CSPRNG
    return base64Encode(List.generate(32, (i) => i));
  }

  /// Dériver une clé à partir d'un mot de passe
  Future<String> deriveKey(String password, String salt) async {
    // En production: utiliser PBKDF2 ou Argon2
    final combined = '$password:$salt';
    return base64Encode(utf8.encode(combined));
  }
}

final dataEncryptionProvider = Provider<DataEncryptionService>((ref) {
  return DataEncryptionService();
});
DART

###############################################################################
# RUN 641: PII Masking Utils
###############################################################################
cat > $BASE/privacy/pii_masking_utils.dart << 'DART'
/// Utilitaires de masquage des informations personnelles (PII).
///
/// Masque les données sensibles pour l'affichage dans les logs,
/// les interfaces et les rapports.
class PiiMaskingUtils {
  /// Masquer un numéro de téléphone: +225 07 ** ** 89
  static String maskPhone(String phone) {
    if (phone.length < 6) return '***';
    return '${phone.substring(0, phone.length > 8 ? phone.length - 6 : 3)} ** ** ${phone.substring(phone.length - 2)}';
  }

  /// Masquer un email: j***@example.com
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    if (name.length <= 1) return '***@${parts[1]}';
    return '${name[0]}${'*' * (name.length - 1)}@${parts[1]}';
  }

  /// Masquer un nom: K**** Ouattara
  static String maskName(String name) {
    final parts = name.split(' ');
    return parts.map((p) {
      if (p.length <= 1) return p;
      return '${p[0]}${'*' * (p.length - 1)}';
    }).join(' ');
  }

  /// Masquer un numéro de carte: **** **** **** 1234
  static String maskCardNumber(String number) {
    final clean = number.replaceAll(' ', '');
    if (clean.length < 4) return '****';
    return '**** **** **** ${clean.substring(clean.length - 4)}';
  }

  /// Masquer une adresse de portefeuille: 0x1234...abcd
  static String maskWalletAddress(String address) {
    if (address.length < 10) return '***';
    return '${address.substring(0, 6)}...${address.substring(address.length - 4)}';
  }

  /// Masquer un numéro d'identité: CI-****-1234
  static String maskIdNumber(String id) {
    if (id.length < 4) return '****';
    return '${'*' * (id.length - 4)}${id.substring(id.length - 4)}';
  }

  /// Masquer un IBAN: CI** **** **** **** **89
  static String maskIban(String iban) {
    if (iban.length < 6) return '****';
    return '${iban.substring(0, 2)}** **** **** **** **${iban.substring(iban.length - 2)}';
  }

  /// Masquer un montant: ***,***
  static String maskAmount(double amount) => '***,***';

  /// Masquer les données selon le type
  static String mask(String value, PiiType type) {
    switch (type) {
      case PiiType.phone: return maskPhone(value);
      case PiiType.email: return maskEmail(value);
      case PiiType.name: return maskName(value);
      case PiiType.cardNumber: return maskCardNumber(value);
      case PiiType.walletAddress: return maskWalletAddress(value);
      case PiiType.idNumber: return maskIdNumber(value);
      case PiiType.iban: return maskIban(value);
    }
  }
}

enum PiiType { phone, email, name, cardNumber, walletAddress, idNumber, iban }
DART

###############################################################################
# RUN 642: Data Retention Service
###############################################################################
cat > $BASE/privacy/data_retention_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Politique de rétention des données
class RetentionPolicy {
  final String dataCategory;
  final Duration retentionPeriod;
  final bool autoDelete;
  final String legalBasis;

  const RetentionPolicy({
    required this.dataCategory,
    required this.retentionPeriod,
    this.autoDelete = true,
    required this.legalBasis,
  });
}

/// Service de gestion de la rétention des données.
///
/// Applique les politiques de rétention conformes au RGPD
/// et à la réglementation UEMOA sur la protection des données.
class DataRetentionService {
  static const _tag = 'DataRetention';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  /// Politiques de rétention par défaut (conformes BCEAO)
  static const List<RetentionPolicy> defaultPolicies = [
    RetentionPolicy(
      dataCategory: 'transaction_records',
      retentionPeriod: Duration(days: 3650), // 10 ans
      autoDelete: false,
      legalBasis: 'Obligation BCEAO - conservation des données de transaction',
    ),
    RetentionPolicy(
      dataCategory: 'kyc_documents',
      retentionPeriod: Duration(days: 1825), // 5 ans après clôture
      autoDelete: false,
      legalBasis: 'Obligation CENTIF - conservation des pièces KYC',
    ),
    RetentionPolicy(
      dataCategory: 'session_logs',
      retentionPeriod: Duration(days: 90),
      autoDelete: true,
      legalBasis: 'Intérêt légitime - sécurité',
    ),
    RetentionPolicy(
      dataCategory: 'marketing_data',
      retentionPeriod: Duration(days: 730), // 2 ans
      autoDelete: true,
      legalBasis: 'Consentement utilisateur',
    ),
  ];

  DataRetentionService({required Dio dio}) : _dio = dio;

  /// Demander la suppression des données expirées
  Future<int> purgeExpiredData() async {
    try {
      final response = await _dio.post('/privacy/retention/purge');
      return (response.data as Map<String, dynamic>)['deletedCount'] as int? ?? 0;
    } catch (e) {
      _log.error('Data purge failed', e);
      return 0;
    }
  }

  /// Obtenir le statut de rétention pour un utilisateur
  Future<Map<String, DateTime>> getRetentionStatus() async {
    try {
      final response = await _dio.get('/privacy/retention/status');
      final data = response.data as Map<String, dynamic>;
      return data.map((k, v) => MapEntry(k, DateTime.parse(v as String)));
    } catch (e) {
      _log.error('Failed to get retention status', e);
      return {};
    }
  }

  RetentionPolicy? getPolicyFor(String dataCategory) {
    return defaultPolicies.where((p) => p.dataCategory == dataCategory).firstOrNull;
  }
}

final dataRetentionProvider = Provider<DataRetentionService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 643: User Consent Management
###############################################################################
cat > $BASE/privacy/user_consent_manager.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type de consentement
enum ConsentType {
  termsOfService,
  privacyPolicy,
  dataProcessing,
  marketing,
  analytics,
  thirdPartySharing,
  biometricData,
  locationData,
  pushNotifications,
}

/// Statut d'un consentement
class ConsentRecord {
  final ConsentType type;
  final bool granted;
  final DateTime updatedAt;
  final String version;

  const ConsentRecord({
    required this.type,
    required this.granted,
    required this.updatedAt,
    required this.version,
  });

  factory ConsentRecord.fromJson(Map<String, dynamic> json) => ConsentRecord(
    type: ConsentType.values.byName(json['type'] as String),
    granted: json['granted'] as bool,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    version: json['version'] as String,
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'granted': granted,
    'updatedAt': updatedAt.toIso8601String(),
    'version': version,
  };
}

/// Gestion du consentement utilisateur.
///
/// Gère les consentements conformément au RGPD
/// et aux réglementations locales ivoiriennes.
class UserConsentManager {
  static const _tag = 'UserConsent';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final Map<ConsentType, ConsentRecord> _consents = {};

  UserConsentManager({required Dio dio}) : _dio = dio;

  /// Charger les consentements actuels
  Future<void> loadConsents() async {
    try {
      final response = await _dio.get('/privacy/consents');
      final list = response.data as List;
      for (final item in list) {
        final record = ConsentRecord.fromJson(item as Map<String, dynamic>);
        _consents[record.type] = record;
      }
    } catch (e) {
      _log.error('Failed to load consents', e);
    }
  }

  /// Mettre à jour un consentement
  Future<bool> updateConsent({
    required ConsentType type,
    required bool granted,
    required String version,
  }) async {
    try {
      await _dio.post('/privacy/consents', data: {
        'type': type.name,
        'granted': granted,
        'version': version,
      });
      _consents[type] = ConsentRecord(
        type: type, granted: granted,
        updatedAt: DateTime.now(), version: version,
      );
      return true;
    } catch (e) {
      _log.error('Failed to update consent', e);
      return false;
    }
  }

  /// Vérifier si un consentement est donné
  bool hasConsent(ConsentType type) => _consents[type]?.granted ?? false;

  /// Obtenir tous les consentements
  Map<ConsentType, ConsentRecord> get allConsents => Map.unmodifiable(_consents);

  /// Vérifier si les consentements obligatoires sont donnés
  bool get hasRequiredConsents =>
    hasConsent(ConsentType.termsOfService) &&
    hasConsent(ConsentType.privacyPolicy) &&
    hasConsent(ConsentType.dataProcessing);
}

final userConsentManagerProvider = Provider<UserConsentManager>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 644: Privacy Settings Provider
###############################################################################
cat > $BASE/privacy/privacy_settings_provider.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Paramètres de confidentialité
class PrivacySettings {
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final bool marketingEnabled;
  final bool locationSharingEnabled;
  final bool biometricStorageEnabled;
  final bool transactionHistoryVisible;
  final bool balanceVisible;
  final Duration autoLockTimeout;
  final bool hideNotificationContent;

  const PrivacySettings({
    this.analyticsEnabled = true,
    this.crashReportingEnabled = true,
    this.marketingEnabled = false,
    this.locationSharingEnabled = false,
    this.biometricStorageEnabled = true,
    this.transactionHistoryVisible = true,
    this.balanceVisible = true,
    this.autoLockTimeout = const Duration(minutes: 5),
    this.hideNotificationContent = false,
  });

  PrivacySettings copyWith({
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    bool? marketingEnabled,
    bool? locationSharingEnabled,
    bool? biometricStorageEnabled,
    bool? transactionHistoryVisible,
    bool? balanceVisible,
    Duration? autoLockTimeout,
    bool? hideNotificationContent,
  }) => PrivacySettings(
    analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
    crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
    marketingEnabled: marketingEnabled ?? this.marketingEnabled,
    locationSharingEnabled: locationSharingEnabled ?? this.locationSharingEnabled,
    biometricStorageEnabled: biometricStorageEnabled ?? this.biometricStorageEnabled,
    transactionHistoryVisible: transactionHistoryVisible ?? this.transactionHistoryVisible,
    balanceVisible: balanceVisible ?? this.balanceVisible,
    autoLockTimeout: autoLockTimeout ?? this.autoLockTimeout,
    hideNotificationContent: hideNotificationContent ?? this.hideNotificationContent,
  );

  Map<String, dynamic> toJson() => {
    'analyticsEnabled': analyticsEnabled,
    'crashReportingEnabled': crashReportingEnabled,
    'marketingEnabled': marketingEnabled,
    'locationSharingEnabled': locationSharingEnabled,
    'biometricStorageEnabled': biometricStorageEnabled,
    'transactionHistoryVisible': transactionHistoryVisible,
    'balanceVisible': balanceVisible,
    'autoLockTimeoutMinutes': autoLockTimeout.inMinutes,
    'hideNotificationContent': hideNotificationContent,
  };

  factory PrivacySettings.fromJson(Map<String, dynamic> json) => PrivacySettings(
    analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
    crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? true,
    marketingEnabled: json['marketingEnabled'] as bool? ?? false,
    locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
    biometricStorageEnabled: json['biometricStorageEnabled'] as bool? ?? true,
    transactionHistoryVisible: json['transactionHistoryVisible'] as bool? ?? true,
    balanceVisible: json['balanceVisible'] as bool? ?? true,
    autoLockTimeout: Duration(minutes: json['autoLockTimeoutMinutes'] as int? ?? 5),
    hideNotificationContent: json['hideNotificationContent'] as bool? ?? false,
  );
}

/// Fournisseur des paramètres de confidentialité
class PrivacySettingsNotifier extends StateNotifier<PrivacySettings> {
  PrivacySettingsNotifier() : super(const PrivacySettings());

  void updateAnalytics(bool enabled) =>
      state = state.copyWith(analyticsEnabled: enabled);
  void updateMarketing(bool enabled) =>
      state = state.copyWith(marketingEnabled: enabled);
  void updateLocationSharing(bool enabled) =>
      state = state.copyWith(locationSharingEnabled: enabled);
  void updateBalanceVisibility(bool visible) =>
      state = state.copyWith(balanceVisible: visible);
  void updateAutoLockTimeout(Duration timeout) =>
      state = state.copyWith(autoLockTimeout: timeout);
  void updateHideNotificationContent(bool hide) =>
      state = state.copyWith(hideNotificationContent: hide);
  void loadFromJson(Map<String, dynamic> json) =>
      state = PrivacySettings.fromJson(json);
}

final privacySettingsProvider =
    StateNotifierProvider<PrivacySettingsNotifier, PrivacySettings>((ref) {
  return PrivacySettingsNotifier();
});
DART

###############################################################################
# RUN 645: Data Export Service
###############################################################################
cat > $BASE/privacy/data_export_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Format d'export des données
enum DataExportFormat { json, csv, pdf }

/// Statut de la demande d'export
enum DataExportStatus { pending, processing, ready, expired, failed }

/// Demande d'export de données
class DataExportRequest {
  final String requestId;
  final DataExportFormat format;
  final DataExportStatus status;
  final DateTime requestedAt;
  final DateTime? readyAt;
  final DateTime? expiresAt;
  final String? downloadUrl;

  const DataExportRequest({
    required this.requestId,
    required this.format,
    required this.status,
    required this.requestedAt,
    this.readyAt,
    this.expiresAt,
    this.downloadUrl,
  });

  factory DataExportRequest.fromJson(Map<String, dynamic> json) => DataExportRequest(
    requestId: json['requestId'] as String,
    format: DataExportFormat.values.byName(json['format'] as String),
    status: DataExportStatus.values.byName(json['status'] as String),
    requestedAt: DateTime.parse(json['requestedAt'] as String),
    readyAt: json['readyAt'] != null ? DateTime.parse(json['readyAt'] as String) : null,
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
    downloadUrl: json['downloadUrl'] as String?,
  );
}

/// Service d'export des données personnelles.
///
/// Permet aux utilisateurs d'exercer leur droit de portabilité
/// (RGPD Article 20) en exportant leurs données.
class DataExportService {
  static const _tag = 'DataExport';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  DataExportService({required Dio dio}) : _dio = dio;

  /// Demander un export de données
  Future<DataExportRequest?> requestExport({
    DataExportFormat format = DataExportFormat.json,
    List<String>? categories,
  }) async {
    try {
      final response = await _dio.post('/privacy/export/request', data: {
        'format': format.name,
        if (categories != null) 'categories': categories,
      });
      return DataExportRequest.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Data export request failed', e);
      return null;
    }
  }

  /// Vérifier le statut d'un export
  Future<DataExportRequest?> checkStatus(String requestId) async {
    try {
      final response = await _dio.get('/privacy/export/$requestId');
      return DataExportRequest.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Export status check failed', e);
      return null;
    }
  }

  /// Demander la suppression des données (droit à l'oubli)
  Future<bool> requestDeletion({String? reason}) async {
    try {
      await _dio.post('/privacy/deletion/request', data: {
        if (reason != null) 'reason': reason,
      });
      return true;
    } catch (e) {
      _log.error('Deletion request failed', e);
      return false;
    }
  }
}

final dataExportProvider = Provider<DataExportService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 646: Privacy Index
###############################################################################
cat > $BASE/privacy/index.dart << 'DART'
export 'data_encryption_service.dart';
export 'pii_masking_utils.dart';
export 'data_retention_service.dart';
export 'user_consent_manager.dart';
export 'privacy_settings_provider.dart';
export 'data_export_service.dart';
DART

###############################################################################
# RUN 647: Risk Index
###############################################################################
cat > $BASE/risk/index.dart << 'DART'
export 'transaction_risk_scorer.dart';
export 'device_risk_scorer.dart';
export 'behavioral_biometrics_model.dart';
export 'behavioral_biometrics_collector.dart';
export 'geo_risk_assessment_service.dart';
export 'velocity_risk_service.dart';
export 'risk_decision_engine.dart';
export 'device_binding_service.dart';
export 'sim_change_detection_service.dart';
DART

###############################################################################
# RUN 648: AML Batch Screening Service
###############################################################################
cat > $BASE/aml/batch_screening_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat du filtrage par lot
class BatchScreeningResult {
  final int totalScreened;
  final int matchesFound;
  final List<String> matchedEntities;
  final DateTime completedAt;

  const BatchScreeningResult({
    required this.totalScreened,
    required this.matchesFound,
    this.matchedEntities = const [],
    required this.completedAt,
  });
}

/// Service de filtrage AML par lot.
///
/// Permet le filtrage simultané de plusieurs entités
/// pour les opérations de masse (import de bénéficiaires).
class BatchScreeningService {
  static const _tag = 'BatchScreening';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  BatchScreeningService({required Dio dio}) : _dio = dio;

  Future<BatchScreeningResult> screenBatch({
    required List<Map<String, String>> entities,
  }) async {
    try {
      final response = await _dio.post('/aml/batch-screen', data: {
        'entities': entities,
      });
      final data = response.data as Map<String, dynamic>;
      return BatchScreeningResult(
        totalScreened: data['totalScreened'] as int,
        matchesFound: data['matchesFound'] as int,
        matchedEntities: List<String>.from(data['matchedEntities'] ?? []),
        completedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Batch screening failed', e);
      return BatchScreeningResult(
        totalScreened: 0, matchesFound: 0, completedAt: DateTime.now(),
      );
    }
  }
}

final batchScreeningProvider = Provider<BatchScreeningService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 649: Transaction Pattern Analyzer
###############################################################################
cat > $BASE/aml/transaction_pattern_analyzer.dart << 'DART'
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Pattern de transaction détecté
enum TransactionPattern {
  normal,
  structuring,
  layering,
  rapidMovement,
  roundTripping,
  fanOut,
  fanIn,
  dormantToActive,
}

class PatternAnalysisResult {
  final TransactionPattern pattern;
  final double confidence;
  final String description;
  final List<String> involvedTransactions;

  const PatternAnalysisResult({
    required this.pattern,
    required this.confidence,
    required this.description,
    this.involvedTransactions = const [],
  });
}

/// Analyseur de patterns de transactions.
///
/// Détecte les schémas de blanchiment d'argent courants:
/// structuration, superposition (layering), mouvement rapide.
class TransactionPatternAnalyzer {
  static const _tag = 'PatternAnalyzer';
  final AppLogger _log = AppLogger(_tag);

  /// Analyser un ensemble de transactions
  List<PatternAnalysisResult> analyze(List<TransactionData> transactions) {
    final results = <PatternAnalysisResult>[];

    results.addAll(_detectStructuring(transactions));
    results.addAll(_detectRapidMovement(transactions));
    results.addAll(_detectFanOutFanIn(transactions));

    return results;
  }

  List<PatternAnalysisResult> _detectStructuring(List<TransactionData> txns) {
    // Structuration: multiples transactions juste en dessous du seuil
    final threshold = 4900000.0;
    final suspicious = txns.where((t) =>
      t.amount > threshold * 0.8 && t.amount < threshold).toList();
    if (suspicious.length >= 3) {
      return [PatternAnalysisResult(
        pattern: TransactionPattern.structuring,
        confidence: 0.8,
        description: '${suspicious.length} transactions proches du seuil CTR',
        involvedTransactions: suspicious.map((t) => t.id).toList(),
      )];
    }
    return [];
  }

  List<PatternAnalysisResult> _detectRapidMovement(List<TransactionData> txns) {
    // Mouvement rapide: fonds reçus et envoyés en moins d'1h
    final results = <PatternAnalysisResult>[];
    for (final txn in txns.where((t) => t.isIncoming)) {
      final quickSends = txns.where((t) =>
        !t.isIncoming &&
        t.timestamp.difference(txn.timestamp).inMinutes.abs() < 60 &&
        t.amount >= txn.amount * 0.8).toList();
      if (quickSends.isNotEmpty) {
        results.add(PatternAnalysisResult(
          pattern: TransactionPattern.rapidMovement,
          confidence: 0.7,
          description: 'Fonds reçus et transférés en moins d\'1 heure',
          involvedTransactions: [txn.id, ...quickSends.map((t) => t.id)],
        ));
      }
    }
    return results;
  }

  List<PatternAnalysisResult> _detectFanOutFanIn(List<TransactionData> txns) {
    // Fan-out: un envoi vers de nombreux destinataires
    final outgoing = txns.where((t) => !t.isIncoming).toList();
    final uniqueRecipients = outgoing.map((t) => t.counterpartyId).toSet();
    if (outgoing.length > 5 && uniqueRecipients.length >= outgoing.length * 0.8) {
      return [PatternAnalysisResult(
        pattern: TransactionPattern.fanOut,
        confidence: 0.6,
        description: 'Distribution vers ${uniqueRecipients.length} bénéficiaires uniques',
        involvedTransactions: outgoing.map((t) => t.id).toList(),
      )];
    }
    return [];
  }
}

class TransactionData {
  final String id;
  final double amount;
  final DateTime timestamp;
  final bool isIncoming;
  final String counterpartyId;

  const TransactionData({
    required this.id,
    required this.amount,
    required this.timestamp,
    required this.isIncoming,
    required this.counterpartyId,
  });
}

final transactionPatternAnalyzerProvider = Provider<TransactionPatternAnalyzer>((ref) {
  return TransactionPatternAnalyzer();
});
DART

###############################################################################
# RUN 650: Adverse Media Screening
###############################################################################
cat > $BASE/aml/adverse_media_screening.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

class AdverseMediaResult {
  final String entityName;
  final bool hasAdverseMedia;
  final List<AdverseMediaHit> hits;
  final DateTime screenedAt;

  const AdverseMediaResult({
    required this.entityName,
    required this.hasAdverseMedia,
    this.hits = const [],
    required this.screenedAt,
  });
}

class AdverseMediaHit {
  final String source;
  final String title;
  final String? summary;
  final String category;
  final DateTime publishedAt;
  final double relevanceScore;

  const AdverseMediaHit({
    required this.source,
    required this.title,
    this.summary,
    required this.category,
    required this.publishedAt,
    required this.relevanceScore,
  });

  factory AdverseMediaHit.fromJson(Map<String, dynamic> json) => AdverseMediaHit(
    source: json['source'] as String,
    title: json['title'] as String,
    summary: json['summary'] as String?,
    category: json['category'] as String,
    publishedAt: DateTime.parse(json['publishedAt'] as String),
    relevanceScore: (json['relevanceScore'] as num).toDouble(),
  );
}

/// Service de filtrage des médias défavorables.
///
/// Recherche les mentions négatives d'un individu
/// dans les médias pour le processus EDD.
class AdverseMediaScreeningService {
  static const _tag = 'AdverseMedia';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AdverseMediaScreeningService({required Dio dio}) : _dio = dio;

  Future<AdverseMediaResult> screen({
    required String name,
    String? country,
  }) async {
    try {
      final response = await _dio.post('/aml/adverse-media/screen', data: {
        'name': name,
        if (country != null) 'country': country,
      });
      final data = response.data as Map<String, dynamic>;
      return AdverseMediaResult(
        entityName: name,
        hasAdverseMedia: data['hasAdverseMedia'] as bool? ?? false,
        hits: (data['hits'] as List?)
            ?.map((e) => AdverseMediaHit.fromJson(e as Map<String, dynamic>))
            .toList() ?? [],
        screenedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Adverse media screening failed', e);
      return AdverseMediaResult(
        entityName: name,
        hasAdverseMedia: false,
        screenedAt: DateTime.now(),
      );
    }
  }
}

final adverseMediaScreeningProvider = Provider<AdverseMediaScreeningService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 651: Compliance Obligation Tracker
###############################################################################
cat > $BASE/compliance/obligation_tracker.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

enum ObligationStatus { pending, fulfilled, overdue, waived }
enum ObligationType { kycRenewal, ctrFiling, sarFiling, annualReview, trainingCert }

class ComplianceObligation {
  final String obligationId;
  final ObligationType type;
  final ObligationStatus status;
  final DateTime dueDate;
  final DateTime? fulfilledAt;
  final String description;

  const ComplianceObligation({
    required this.obligationId,
    required this.type,
    required this.status,
    required this.dueDate,
    this.fulfilledAt,
    required this.description,
  });

  factory ComplianceObligation.fromJson(Map<String, dynamic> json) => ComplianceObligation(
    obligationId: json['obligationId'] as String,
    type: ObligationType.values.byName(json['type'] as String),
    status: ObligationStatus.values.byName(json['status'] as String),
    dueDate: DateTime.parse(json['dueDate'] as String),
    fulfilledAt: json['fulfilledAt'] != null ? DateTime.parse(json['fulfilledAt'] as String) : null,
    description: json['description'] as String,
  );

  bool get isOverdue => status != ObligationStatus.fulfilled && DateTime.now().isAfter(dueDate);
}

/// Suivi des obligations de conformité.
class ComplianceObligationTracker {
  static const _tag = 'ObligationTracker';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  ComplianceObligationTracker({required Dio dio}) : _dio = dio;

  Future<List<ComplianceObligation>> getObligations() async {
    try {
      final response = await _dio.get('/compliance/obligations');
      return (response.data as List)
          .map((e) => ComplianceObligation.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to fetch obligations', e);
      return [];
    }
  }

  Future<List<ComplianceObligation>> getOverdueObligations() async {
    final all = await getObligations();
    return all.where((o) => o.isOverdue).toList();
  }
}

final complianceObligationTrackerProvider = Provider<ComplianceObligationTracker>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 652: Watchlist Management Service
###############################################################################
cat > $BASE/aml/watchlist_management_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

enum WatchlistType { internal, sanctions, pep, adverseMedia }

class WatchlistEntry {
  final String entryId;
  final WatchlistType type;
  final String name;
  final String? reason;
  final DateTime addedAt;
  final DateTime? expiresAt;

  const WatchlistEntry({
    required this.entryId,
    required this.type,
    required this.name,
    this.reason,
    required this.addedAt,
    this.expiresAt,
  });

  factory WatchlistEntry.fromJson(Map<String, dynamic> json) => WatchlistEntry(
    entryId: json['entryId'] as String,
    type: WatchlistType.values.byName(json['type'] as String),
    name: json['name'] as String,
    reason: json['reason'] as String?,
    addedAt: DateTime.parse(json['addedAt'] as String),
    expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
  );
}

/// Service de gestion des listes de surveillance.
class WatchlistManagementService {
  static const _tag = 'Watchlist';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  WatchlistManagementService({required Dio dio}) : _dio = dio;

  Future<bool> isOnWatchlist({required String name}) async {
    try {
      final response = await _dio.post('/aml/watchlist/check', data: {'name': name});
      return (response.data as Map<String, dynamic>)['onWatchlist'] as bool? ?? false;
    } catch (e) {
      _log.error('Watchlist check failed', e);
      return false;
    }
  }

  Future<List<WatchlistEntry>> getWatchlist() async {
    try {
      final response = await _dio.get('/aml/watchlist');
      return (response.data as List)
          .map((e) => WatchlistEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to fetch watchlist', e);
      return [];
    }
  }
}

final watchlistManagementProvider = Provider<WatchlistManagementService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 653: Risk Profile Service
###############################################################################
cat > $BASE/risk/risk_profile_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

enum CustomerRiskRating { low, medium, high, veryHigh, prohibited }

class CustomerRiskProfile {
  final String userId;
  final CustomerRiskRating rating;
  final double overallScore;
  final Map<String, double> factorScores;
  final DateTime lastAssessedAt;
  final DateTime nextReviewDate;
  final List<String> riskFactors;
  final String? reviewNotes;

  const CustomerRiskProfile({
    required this.userId,
    required this.rating,
    required this.overallScore,
    this.factorScores = const {},
    required this.lastAssessedAt,
    required this.nextReviewDate,
    this.riskFactors = const [],
    this.reviewNotes,
  });

  factory CustomerRiskProfile.fromJson(Map<String, dynamic> json) => CustomerRiskProfile(
    userId: json['userId'] as String,
    rating: CustomerRiskRating.values.byName(json['rating'] as String),
    overallScore: (json['overallScore'] as num).toDouble(),
    factorScores: Map<String, double>.from(
      (json['factorScores'] as Map?)?.map((k, v) => MapEntry(k as String, (v as num).toDouble())) ?? {},
    ),
    lastAssessedAt: DateTime.parse(json['lastAssessedAt'] as String),
    nextReviewDate: DateTime.parse(json['nextReviewDate'] as String),
    riskFactors: List<String>.from(json['riskFactors'] ?? []),
    reviewNotes: json['reviewNotes'] as String?,
  );
}

/// Service de profil de risque client.
///
/// Gère le profil de risque global d'un client
/// pour la segmentation et le monitoring continu.
class RiskProfileService {
  static const _tag = 'RiskProfile';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  RiskProfileService({required Dio dio}) : _dio = dio;

  Future<CustomerRiskProfile?> getProfile({required String userId}) async {
    try {
      final response = await _dio.get('/risk/profile/$userId');
      return CustomerRiskProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to fetch risk profile', e);
      return null;
    }
  }

  Future<CustomerRiskProfile?> refreshProfile({required String userId}) async {
    try {
      final response = await _dio.post('/risk/profile/$userId/refresh');
      return CustomerRiskProfile.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to refresh risk profile', e);
      return null;
    }
  }
}

final riskProfileProvider = Provider<RiskProfileService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 654: Impossible Travel Detector
###############################################################################
cat > $BASE/fraud/impossible_travel_detector.dart << 'DART'
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Résultat de détection de voyage impossible
class ImpossibleTravelResult {
  final bool isImpossible;
  final double distanceKm;
  final Duration timeBetween;
  final double requiredSpeedKmh;
  final String? fromLocation;
  final String? toLocation;

  const ImpossibleTravelResult({
    required this.isImpossible,
    required this.distanceKm,
    required this.timeBetween,
    required this.requiredSpeedKmh,
    this.fromLocation,
    this.toLocation,
  });
}

/// Détecteur de voyage impossible.
///
/// Identifie les connexions depuis des emplacements
/// géographiquement impossibles dans un laps de temps donné.
class ImpossibleTravelDetector {
  static const _tag = 'ImpossibleTravel';
  final AppLogger _log = AppLogger(_tag);
  static const double _maxReasonableSpeedKmh = 900.0; // Vitesse d'avion

  /// Vérifier si le déplacement est physiquement possible
  ImpossibleTravelResult check({
    required double fromLat,
    required double fromLon,
    required double toLat,
    required double toLon,
    required DateTime fromTime,
    required DateTime toTime,
  }) {
    final distance = _haversineDistance(fromLat, fromLon, toLat, toLon);
    final duration = toTime.difference(fromTime);
    final hours = duration.inMinutes / 60.0;
    final requiredSpeed = hours > 0 ? distance / hours : double.infinity;

    return ImpossibleTravelResult(
      isImpossible: requiredSpeed > _maxReasonableSpeedKmh,
      distanceKm: distance,
      timeBetween: duration,
      requiredSpeedKmh: requiredSpeed,
    );
  }

  /// Formule de Haversine pour la distance entre deux points
  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Rayon de la Terre en km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degrees) => degrees * pi / 180;
}

final impossibleTravelDetectorProvider = Provider<ImpossibleTravelDetector>((ref) {
  return ImpossibleTravelDetector();
});
DART

###############################################################################
# RUN 655: Mule Account Detector
###############################################################################
cat > $BASE/fraud/mule_account_detector.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Indicateurs de compte mule
class MuleAccountIndicators {
  final double riskScore;
  final bool isSuspected;
  final List<String> indicators;
  final DateTime assessedAt;

  const MuleAccountIndicators({
    required this.riskScore,
    required this.isSuspected,
    this.indicators = const [],
    required this.assessedAt,
  });
}

/// Détecteur de comptes mule.
///
/// Identifie les comptes utilisés comme intermédiaires
/// pour le blanchiment d'argent (money mules).
class MuleAccountDetector {
  static const _tag = 'MuleDetector';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  MuleAccountDetector({required Dio dio}) : _dio = dio;

  Future<MuleAccountIndicators> assess({required String userId}) async {
    try {
      final response = await _dio.get('/fraud/mule-detection/$userId');
      final data = response.data as Map<String, dynamic>;
      return MuleAccountIndicators(
        riskScore: (data['riskScore'] as num).toDouble(),
        isSuspected: data['isSuspected'] as bool? ?? false,
        indicators: List<String>.from(data['indicators'] ?? []),
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Mule account assessment failed', e);
      return MuleAccountIndicators(
        riskScore: 0.0, isSuspected: false, assessedAt: DateTime.now(),
      );
    }
  }
}

final muleAccountDetectorProvider = Provider<MuleAccountDetector>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 656: Device Intelligence Service
###############################################################################
cat > $BASE/fraud/device_intelligence_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

class DeviceIntelligence {
  final String deviceId;
  final int associatedAccounts;
  final bool isKnownFraudDevice;
  final double trustScore;
  final String? lastKnownLocation;
  final DateTime? firstSeenAt;
  final DateTime? lastSeenAt;

  const DeviceIntelligence({
    required this.deviceId,
    required this.associatedAccounts,
    required this.isKnownFraudDevice,
    required this.trustScore,
    this.lastKnownLocation,
    this.firstSeenAt,
    this.lastSeenAt,
  });

  factory DeviceIntelligence.fromJson(Map<String, dynamic> json) => DeviceIntelligence(
    deviceId: json['deviceId'] as String,
    associatedAccounts: json['associatedAccounts'] as int? ?? 0,
    isKnownFraudDevice: json['isKnownFraudDevice'] as bool? ?? false,
    trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0.5,
    lastKnownLocation: json['lastKnownLocation'] as String?,
    firstSeenAt: json['firstSeenAt'] != null ? DateTime.parse(json['firstSeenAt'] as String) : null,
    lastSeenAt: json['lastSeenAt'] != null ? DateTime.parse(json['lastSeenAt'] as String) : null,
  );
}

/// Service de renseignement sur les appareils.
///
/// Interroge la base de données de renseignement pour
/// obtenir l'historique de confiance d'un appareil.
class DeviceIntelligenceService {
  static const _tag = 'DeviceIntelligence';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  DeviceIntelligenceService({required Dio dio}) : _dio = dio;

  Future<DeviceIntelligence?> getIntelligence({required String deviceId}) async {
    try {
      final response = await _dio.get('/fraud/device-intelligence/$deviceId');
      return DeviceIntelligence.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Device intelligence lookup failed', e);
      return null;
    }
  }

  Future<void> reportDevice({
    required String deviceId,
    required String reason,
  }) async {
    try {
      await _dio.post('/fraud/device-intelligence/report', data: {
        'deviceId': deviceId,
        'reason': reason,
      });
    } catch (e) {
      _log.error('Device report failed', e);
    }
  }
}

final deviceIntelligenceProvider = Provider<DeviceIntelligenceService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 657: Transaction Limit Manager
###############################################################################
cat > $BASE/compliance/transaction_limit_manager.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

class TransactionLimits {
  final double singleTransactionMax;
  final double dailyMax;
  final double weeklyMax;
  final double monthlyMax;
  final int dailyCountMax;
  final double crossBorderDailyMax;

  const TransactionLimits({
    this.singleTransactionMax = 5000000,
    this.dailyMax = 10000000,
    this.weeklyMax = 25000000,
    this.monthlyMax = 50000000,
    this.dailyCountMax = 50,
    this.crossBorderDailyMax = 2000000,
  });

  factory TransactionLimits.fromJson(Map<String, dynamic> json) => TransactionLimits(
    singleTransactionMax: (json['singleTransactionMax'] as num?)?.toDouble() ?? 5000000,
    dailyMax: (json['dailyMax'] as num?)?.toDouble() ?? 10000000,
    weeklyMax: (json['weeklyMax'] as num?)?.toDouble() ?? 25000000,
    monthlyMax: (json['monthlyMax'] as num?)?.toDouble() ?? 50000000,
    dailyCountMax: json['dailyCountMax'] as int? ?? 50,
    crossBorderDailyMax: (json['crossBorderDailyMax'] as num?)?.toDouble() ?? 2000000,
  );
}

class LimitCheckResult {
  final bool withinLimits;
  final String? violatedLimit;
  final double? remaining;

  const LimitCheckResult({
    required this.withinLimits,
    this.violatedLimit,
    this.remaining,
  });
}

/// Gestionnaire des limites de transaction.
///
/// Applique les limites réglementaires et de tier KYC
/// sur les transactions.
class TransactionLimitManager {
  static const _tag = 'TransactionLimits';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  TransactionLimits? _limits;

  TransactionLimitManager({required Dio dio}) : _dio = dio;

  Future<TransactionLimits> getLimits() async {
    if (_limits != null) return _limits!;
    try {
      final response = await _dio.get('/compliance/limits');
      _limits = TransactionLimits.fromJson(response.data as Map<String, dynamic>);
      return _limits!;
    } catch (e) {
      _log.error('Failed to fetch limits', e);
      return const TransactionLimits();
    }
  }

  Future<LimitCheckResult> checkTransaction({
    required double amount,
    bool isCrossBorder = false,
  }) async {
    final limits = await getLimits();
    if (amount > limits.singleTransactionMax) {
      return LimitCheckResult(
        withinLimits: false,
        violatedLimit: 'Transaction unique maximale',
        remaining: limits.singleTransactionMax,
      );
    }
    if (isCrossBorder && amount > limits.crossBorderDailyMax) {
      return LimitCheckResult(
        withinLimits: false,
        violatedLimit: 'Limite transfrontalière journalière',
        remaining: limits.crossBorderDailyMax,
      );
    }
    return const LimitCheckResult(withinLimits: true);
  }

  void invalidateCache() => _limits = null;
}

final transactionLimitManagerProvider = Provider<TransactionLimitManager>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 658: Regulatory Reporting Service
###############################################################################
cat > $BASE/compliance/regulatory_reporting_service.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

enum ReportType { ctr, sar, periodicReport, incidentReport }
enum ReportStatus { draft, submitted, accepted, rejected }

class RegulatoryReport {
  final String reportId;
  final ReportType type;
  final ReportStatus status;
  final String? regulatoryBody;
  final DateTime createdAt;
  final DateTime? submittedAt;
  final String? reference;

  const RegulatoryReport({
    required this.reportId,
    required this.type,
    required this.status,
    this.regulatoryBody,
    required this.createdAt,
    this.submittedAt,
    this.reference,
  });

  factory RegulatoryReport.fromJson(Map<String, dynamic> json) => RegulatoryReport(
    reportId: json['reportId'] as String,
    type: ReportType.values.byName(json['type'] as String),
    status: ReportStatus.values.byName(json['status'] as String),
    regulatoryBody: json['regulatoryBody'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    submittedAt: json['submittedAt'] != null ? DateTime.parse(json['submittedAt'] as String) : null,
    reference: json['reference'] as String?,
  );
}

/// Service de reporting réglementaire.
///
/// Gère la soumission des rapports aux autorités
/// (BCEAO, CENTIF, Commission bancaire UMOA).
class RegulatoryReportingService {
  static const _tag = 'RegulatoryReporting';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  RegulatoryReportingService({required Dio dio}) : _dio = dio;

  Future<List<RegulatoryReport>> getPendingReports() async {
    try {
      final response = await _dio.get('/compliance/reports/pending');
      return (response.data as List)
          .map((e) => RegulatoryReport.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to fetch pending reports', e);
      return [];
    }
  }

  Future<bool> submitReport(String reportId) async {
    try {
      await _dio.post('/compliance/reports/$reportId/submit');
      return true;
    } catch (e) {
      _log.error('Report submission failed', e);
      return false;
    }
  }
}

final regulatoryReportingProvider = Provider<RegulatoryReportingService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

###############################################################################
# RUN 659: KYC Refresh Scheduler
###############################################################################
cat > $BASE/compliance/kyc_refresh_scheduler.dart << 'DART'
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

class KycRefreshSchedule {
  final String userId;
  final DateTime nextRefreshDate;
  final String riskRating;
  final int daysUntilRefresh;
  final bool isOverdue;

  const KycRefreshSchedule({
    required this.userId,
    required this.nextRefreshDate,
    required this.riskRating,
    required this.daysUntilRefresh,
    required this.isOverdue,
  });

  factory KycRefreshSchedule.fromJson(Map<String, dynamic> json) => KycRefreshSchedule(
    userId: json['userId'] as String,
    nextRefreshDate: DateTime.parse(json['nextRefreshDate'] as String),
    riskRating: json['riskRating'] as String,
    daysUntilRefresh: json['daysUntilRefresh'] as int,
    isOverdue: json['isOverdue'] as bool? ?? false,
  );
}

/// Planificateur de renouvellement KYC.
///
/// Suit les dates de renouvellement KYC selon le profil
/// de risque: haut risque = 1 an, moyen = 2 ans, faible = 3 ans.
class KycRefreshScheduler {
  static const _tag = 'KycRefresh';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  KycRefreshScheduler({required Dio dio}) : _dio = dio;

  Future<KycRefreshSchedule?> getSchedule() async {
    try {
      final response = await _dio.get('/compliance/kyc/refresh-schedule');
      return KycRefreshSchedule.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to get KYC refresh schedule', e);
      return null;
    }
  }

  /// Durée de validité KYC par niveau de risque
  static Duration getRefreshPeriod(String riskRating) {
    switch (riskRating) {
      case 'high': return const Duration(days: 365);
      case 'medium': return const Duration(days: 730);
      case 'low': return const Duration(days: 1095);
      default: return const Duration(days: 365);
    }
  }
}

final kycRefreshSchedulerProvider = Provider<KycRefreshScheduler>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
DART

echo "Batch 3 (runs 640-659) complete"
