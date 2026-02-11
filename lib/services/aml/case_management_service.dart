import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

enum AmlCaseStatus { open, investigating, escalated, resolved, closed }
enum AmlCasePriority { low, medium, high, critical }

class AmlCase {
  final String caseId;
  final String userId;
  final AmlCaseStatus status;
  final AmlCasePriority priority;
  final String description;
  final List<String> relatedTransactions;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? assignedTo;
  final List<AmlCaseNote> notes;

  const AmlCase({
    required this.caseId,
    required this.userId,
    required this.status,
    required this.priority,
    required this.description,
    this.relatedTransactions = const [],
    required this.createdAt,
    this.resolvedAt,
    this.assignedTo,
    this.notes = const [],
  });

  factory AmlCase.fromJson(Map<String, dynamic> json) => AmlCase(
    caseId: json['caseId'] as String,
    userId: json['userId'] as String,
    status: AmlCaseStatus.values.byName(json['status'] as String),
    priority: AmlCasePriority.values.byName(json['priority'] as String),
    description: json['description'] as String,
    relatedTransactions: List<String>.from(json['relatedTransactions'] ?? []),
    createdAt: DateTime.parse(json['createdAt'] as String),
    resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
    assignedTo: json['assignedTo'] as String?,
  );
}

class AmlCaseNote {
  final String noteId;
  final String content;
  final String author;
  final DateTime createdAt;

  const AmlCaseNote({
    required this.noteId,
    required this.content,
    required this.author,
    required this.createdAt,
  });
}

/// Gestion des dossiers AML.
class AmlCaseManagementService {
  static const _tag = 'AmlCaseManagement';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  AmlCaseManagementService({required Dio dio}) : _dio = dio;

  Future<List<AmlCase>> getActiveCases({required String userId}) async {
    try {
      final response = await _dio.get('/aml/cases', queryParameters: {'userId': userId});
      final list = response.data as List;
      return list.map((e) => AmlCase.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      _log.error('Failed to fetch AML cases', e);
      return [];
    }
  }

  Future<AmlCase?> getCaseDetails({required String caseId}) async {
    try {
      final response = await _dio.get('/aml/cases/$caseId');
      return AmlCase.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      _log.error('Failed to fetch case details', e);
      return null;
    }
  }
}

final amlCaseManagementProvider = Provider<AmlCaseManagementService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
