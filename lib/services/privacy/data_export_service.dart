import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/api/api_client.dart';
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

/// Service d'export des donnees personnelles.
///
/// Customer-facing export uses the verified account export route. Async privacy
/// request/deletion routes stay server-owned until the backend exposes them for
/// customer use.
class DataExportService {
  static const _tag = 'DataExport';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  DataExportService({required Dio dio}) : _dio = dio;

  /// Demander un export de données
  Future<Map<String, dynamic>?> exportAccountData() async {
    try {
      final response = await _dio.get('/user/data-export', queryParameters: {
        'includeProfile': true,
        'includeTransactions': false,
        'includeContacts': false,
        'format': 'json',
      });
      final data = response.data;
      return data is Map<String, dynamic> ? data : {'data': data};
    } catch (e) {
      _log.error('Account data export failed', e);
      return null;
    }
  }
}

final dataExportProvider = Provider<DataExportService>((ref) {
  return DataExportService(dio: ref.watch(dioProvider));
});
