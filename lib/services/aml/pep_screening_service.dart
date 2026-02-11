import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

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
