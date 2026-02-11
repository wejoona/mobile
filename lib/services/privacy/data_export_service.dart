import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

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
