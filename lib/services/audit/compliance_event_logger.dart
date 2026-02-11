import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Type d'événement de conformité
enum ComplianceEventType {
  kycCompleted,
  kycExpired,
  amlAlert,
  sanctionsHit,
  pepIdentified,
  ctrFiled,
  sarFiled,
  limitBreached,
  regulatoryChange,
  auditRequest,
  dataAccessRequest,
  consentChange,
}

/// Événement de conformité
class ComplianceEvent {
  final String eventId;
  final ComplianceEventType type;
  final String description;
  final String? userId;
  final String? transactionId;
  final Map<String, dynamic> data;
  final DateTime timestamp;

  const ComplianceEvent({
    required this.eventId,
    required this.type,
    required this.description,
    this.userId,
    this.transactionId,
    this.data = const {},
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'eventId': eventId,
    'type': type.name,
    'description': description,
    if (userId != null) 'userId': userId,
    if (transactionId != null) 'transactionId': transactionId,
    'data': data,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Journal des événements de conformité.
///
/// Enregistre tous les événements liés à la conformité
/// réglementaire pour le reporting BCEAO et CENTIF.
class ComplianceEventLogger {
  static const _tag = 'ComplianceEventLogger';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;
  final List<ComplianceEvent> _buffer = [];

  ComplianceEventLogger({required Dio dio}) : _dio = dio;

  void log({
    required ComplianceEventType type,
    required String description,
    String? userId,
    String? transactionId,
    Map<String, dynamic>? data,
  }) {
    _buffer.add(ComplianceEvent(
      eventId: '${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      description: description,
      userId: userId,
      transactionId: transactionId,
      data: data ?? {},
      timestamp: DateTime.now(),
    ));
  }

  Future<void> flush() async {
    if (_buffer.isEmpty) return;
    final batch = List<ComplianceEvent>.from(_buffer);
    _buffer.clear();
    try {
      await _dio.post('/audit/compliance-events/batch', data: {
        'events': batch.map((e) => e.toJson()).toList(),
      });
    } catch (e) {
      _log.error('Failed to flush compliance events', e);
      _buffer.insertAll(0, batch);
    }
  }
}

final complianceEventLoggerProvider = Provider<ComplianceEventLogger>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
