import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/fraud/fraud_case_model.dart';

/// Service de signalement de fraude.
///
/// Permet aux utilisateurs de signaler des transactions
/// frauduleuses et de suivre leurs dossiers.
class FraudReportingService {
  static const _tag = 'FraudReporting';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  FraudReportingService({required Dio dio}) : _dio = dio;

  /// Signaler une fraude
  Future<FraudCase?> reportFraud({
    required FraudType fraudType,
    required String description,
    required List<String> transactionIds,
  }) async {
    try {
      final response = await _dio.post('/fraud/report', data: {
        'fraudType': fraudType.name,
        'description': description,
        'transactionIds': transactionIds,
      });
      return FraudCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Fraud report failed', e);
      return null;
    }
  }

  /// Obtenir les dossiers de fraude de l'utilisateur
  Future<List<FraudCase>> getMyCases() async {
    try {
      final response = await _dio.get('/fraud/cases/mine');
      return (response.data as List)
          .map((e) => FraudCase.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _log.error('Failed to fetch fraud cases', e);
      return [];
    }
  }

  /// Obtenir les détails d'un dossier
  Future<FraudCase?> getCaseDetails(String caseId) async {
    try {
      final response = await _dio.get('/fraud/cases/$caseId');
      return FraudCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to fetch case details', e);
      return null;
    }
  }
}

final fraudReportingProvider = Provider<FraudReportingService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
