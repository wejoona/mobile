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
