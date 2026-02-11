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
