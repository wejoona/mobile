import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

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
