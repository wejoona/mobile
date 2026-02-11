import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Niveau de risque géographique
enum GeoRiskLevel { low, medium, high, prohibited }

/// Évaluation du risque géographique
class GeoRiskAssessment {
  final String countryCode;
  final GeoRiskLevel riskLevel;
  final double score;
  final List<String> reasons;
  final bool isProhibited;
  final DateTime assessedAt;

  const GeoRiskAssessment({
    required this.countryCode,
    required this.riskLevel,
    required this.score,
    this.reasons = const [],
    this.isProhibited = false,
    required this.assessedAt,
  });
}

/// Service d'évaluation du risque géographique.
///
/// Évalue le risque lié à la localisation de l'utilisateur
/// et des bénéficiaires selon les listes GAFI et UEMOA.
class GeoRiskAssessmentService {
  static const _tag = 'GeoRisk';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  // Pays à haut risque selon le GAFI (liste grise/noire)
  static const Set<String> _highRiskCountries = {
    'KP', 'IR', 'MM', 'SY', 'YE', 'AF',
  };

  // Pays UEMOA (risque réduit pour les transferts intra-zone)
  static const Set<String> _uemoaCountries = {
    'BJ', 'BF', 'CI', 'GW', 'ML', 'NE', 'SN', 'TG',
  };

  GeoRiskAssessmentService({required Dio dio}) : _dio = dio;

  /// Évaluer le risque géographique d'un pays
  Future<GeoRiskAssessment> assessCountry(String countryCode) async {
    // Vérification locale rapide
    if (_highRiskCountries.contains(countryCode)) {
      return GeoRiskAssessment(
        countryCode: countryCode,
        riskLevel: GeoRiskLevel.prohibited,
        score: 1.0,
        reasons: ['Pays sous sanctions internationales'],
        isProhibited: true,
        assessedAt: DateTime.now(),
      );
    }

    try {
      final response = await _dio.get('/risk/geo/$countryCode');
      final data = response.data as Map<String, dynamic>;
      return GeoRiskAssessment(
        countryCode: countryCode,
        riskLevel: GeoRiskLevel.values.byName(data['riskLevel'] as String),
        score: (data['score'] as num).toDouble(),
        reasons: List<String>.from(data['reasons'] ?? []),
        isProhibited: data['isProhibited'] as bool? ?? false,
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('Geo risk assessment failed', e);
      final isUemoa = _uemoaCountries.contains(countryCode);
      return GeoRiskAssessment(
        countryCode: countryCode,
        riskLevel: isUemoa ? GeoRiskLevel.low : GeoRiskLevel.medium,
        score: isUemoa ? 0.1 : 0.4,
        assessedAt: DateTime.now(),
      );
    }
  }

  /// Vérifier si un transfert transfrontalier est autorisé
  Future<bool> isTransferAllowed({
    required String fromCountry,
    required String toCountry,
  }) async {
    final assessment = await assessCountry(toCountry);
    return !assessment.isProhibited;
  }

  bool isUemoaCountry(String countryCode) => _uemoaCountries.contains(countryCode);
}

final geoRiskAssessmentProvider = Provider<GeoRiskAssessmentService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
