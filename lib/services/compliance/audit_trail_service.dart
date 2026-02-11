import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Maintains immutable audit trail for regulatory compliance.
class AuditTrailService {
  static const _tag = 'AuditTrail';
  final AppLogger _log = AppLogger(_tag);
  final List<AuditRecord> _records = [];

  /// Record an auditable action.
  void record({
    required String action,
    required String userId,
    required String entityType,
    String? entityId,
    Map<String, dynamic>? before,
    Map<String, dynamic>? after,
  }) {
    _records.add(AuditRecord(
      action: action,
      userId: userId,
      entityType: entityType,
      entityId: entityId,
      before: before,
      after: after,
      timestamp: DateTime.now(),
    ));
    _log.debug('Audit: $action on $entityType by $userId');
  }

  List<AuditRecord> getRecords({String? userId, String? entityType, int limit = 100}) {
    var results = _records.reversed.toList();
    if (userId != null) results = results.where((r) => r.userId == userId).toList();
    if (entityType != null) results = results.where((r) => r.entityType == entityType).toList();
    return results.take(limit).toList();
  }
}

class AuditRecord {
  final String action;
  final String userId;
  final String entityType;
  final String? entityId;
  final Map<String, dynamic>? before;
  final Map<String, dynamic>? after;
  final DateTime timestamp;

  const AuditRecord({
    required this.action,
    required this.userId,
    required this.entityType,
    this.entityId,
    this.before,
    this.after,
    required this.timestamp,
  });
}

final auditTrailServiceProvider = Provider<AuditTrailService>((ref) {
  return AuditTrailService();
});
