import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Indicateur de prise de contrôle de compte
enum AtoIndicator {
  passwordChanged,
  emailChanged,
  phoneChanged,
  newDeviceLogin,
  impossibleTravel,
  simSwap,
  bulkSettingsChange,
  beneficiaryFlood,
}

/// Résultat de l'évaluation ATO
class AtoAssessment {
  final double riskScore;
  final List<AtoIndicator> indicators;
  final bool accountLocked;
  final String? recommendedAction;
  final DateTime assessedAt;

  const AtoAssessment({
    required this.riskScore,
    this.indicators = const [],
    this.accountLocked = false,
    this.recommendedAction,
    required this.assessedAt,
  });
}

/// Service de prévention de prise de contrôle de compte (ATO).
///
/// Détecte les signes de compromission de compte et prend
/// des mesures préventives automatiques.
class AccountTakeoverPreventionService {
  static const _tag = 'ATOPrevention';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AccountTakeoverPreventionService({required Dio dio}) : _dio = dio;

  /// Évaluer le risque ATO pour la session actuelle
  Future<AtoAssessment> assessRisk({
    required String userId,
    required String deviceId,
    String? ipAddress,
    String? location,
  }) async {
    try {
      final response = await _dio.post('/fraud/ato/assess', data: {
        'userId': userId,
        'deviceId': deviceId,
        if (ipAddress != null) 'ipAddress': ipAddress,
        if (location != null) 'location': location,
      });
      final data = response.data as Map<String, dynamic>;
      return AtoAssessment(
        riskScore: (data['riskScore'] as num).toDouble(),
        indicators: (data['indicators'] as List?)
            ?.map((e) => AtoIndicator.values.byName(e as String))
            .toList() ?? [],
        accountLocked: data['accountLocked'] as bool? ?? false,
        recommendedAction: data['recommendedAction'] as String?,
        assessedAt: DateTime.now(),
      );
    } catch (e) {
      _log.error('ATO assessment failed', e);
      return AtoAssessment(riskScore: 0.0, assessedAt: DateTime.now());
    }
  }

  /// Signaler un changement sensible de compte
  Future<void> reportSensitiveChange({
    required String userId,
    required AtoIndicator changeType,
  }) async {
    try {
      await _dio.post('/fraud/ato/report-change', data: {
        'userId': userId,
        'changeType': changeType.name,
      });
    } catch (e) {
      _log.error('Failed to report sensitive change', e);
    }
  }
}

final accountTakeoverPreventionProvider = Provider<AccountTakeoverPreventionService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
