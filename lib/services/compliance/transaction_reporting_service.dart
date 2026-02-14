import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/compliance/bceao_reporting_models.dart';

/// Handles submission of regulatory transaction reports to the backend.
///
/// The backend aggregates and forwards reports to BCEAO and CENTIF
/// (Cellule Nationale de Traitement des Informations Financieres).
class TransactionReportingService {
  static const _tag = 'TxReporting';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  TransactionReportingService({required Dio dio}) : _dio = dio;

  /// Submit a suspicious transaction report (STR).
  Future<bool> submitSuspiciousReport({
    required String transactionId,
    required String reason,
    required double amountCfa,
    Map<String, dynamic>? additionalInfo,
  }) async {
    try {
      await _dio.post('/compliance/reports/suspicious', data: {
        'transactionId': transactionId,
        'reason': reason,
        'amountCfa': amountCfa,
        'reportedAt': DateTime.now().toIso8601String(),
        if (additionalInfo != null) ...additionalInfo,
      });
      _log.debug('STR submitted for transaction: $transactionId');
      return true;
    } catch (e) {
      _log.error('Failed to submit STR', e);
      return false;
    }
  }

  /// Submit a large transaction report.
  Future<bool> submitLargeTransactionReport({
    required BceaoTransactionEntry entry,
  }) async {
    try {
      await _dio.post('/compliance/reports/large-transaction',
          data: entry.toJson());
      _log.debug('Large tx report submitted: ${entry.transactionId}');
      return true;
    } catch (e) {
      _log.error('Failed to submit large tx report', e);
      return false;
    }
  }

  /// Fetch pending reports for the current user.
  Future<List<Map<String, dynamic>>> getPendingReports() async {
    try {
      final response = await _dio.get('/compliance/reports/pending');
      // ignore: avoid_dynamic_calls
      return List<Map<String, dynamic>>.from(response.data['reports'] ?? []);
    } catch (e) {
      _log.error('Failed to fetch pending reports', e);
      return [];
    }
  }
}

final transactionReportingServiceProvider =
    Provider<TransactionReportingService>((ref) {
  // Assumes a Dio provider exists in the app
  return TransactionReportingService(dio: Dio());
});
