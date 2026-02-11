import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Audit log entry.
class AuditLogEntry {
  final String id;
  final String action;
  final String actor;
  final Map<String, dynamic> details;
  final DateTime timestamp;
  final bool success;

  const AuditLogEntry({
    required this.id,
    required this.action,
    required this.actor,
    required this.details,
    required this.timestamp,
    required this.success,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'action': action,
    'actor': actor,
    'details': details,
    'timestamp': timestamp.toIso8601String(),
    'success': success,
  };
}

/// Records security-relevant actions for audit compliance.
class SecurityAuditService {
  static const _tag = 'SecurityAudit';
  final AppLogger _log = AppLogger(_tag);

  final List<AuditLogEntry> _entries = [];
  static const int _maxEntries = 500;

  /// Log a security action.
  void logAction({
    required String action,
    required String actor,
    Map<String, dynamic> details = const {},
    bool success = true,
  }) {
    final entry = AuditLogEntry(
      id: '${DateTime.now().millisecondsSinceEpoch}_$action',
      action: action,
      actor: actor,
      details: details,
      timestamp: DateTime.now(),
      success: success,
    );

    _entries.add(entry);
    if (_entries.length > _maxEntries) {
      _entries.removeAt(0);
    }

    _log.debug('Audit: $action by $actor (${success ? "OK" : "FAIL"})');
  }

  /// Export audit log entries.
  List<Map<String, dynamic>> export({DateTime? since}) {
    final filtered = since != null
        ? _entries.where((e) => e.timestamp.isAfter(since)).toList()
        : _entries;
    return filtered.map((e) => e.toJson()).toList();
  }

  List<AuditLogEntry> get entries => List.unmodifiable(_entries);
}

final securityAuditServiceProvider =
    Provider<SecurityAuditService>((ref) {
  return SecurityAuditService();
});
