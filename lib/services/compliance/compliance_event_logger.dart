import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Types of compliance events to log.
enum ComplianceEventType {
  limitCheck,
  amlScreening,
  crossBorderFlag,
  sourceOfFundsRequired,
  reportSubmitted,
  kycTierChange,
  regulatoryAlert,
}

/// A compliance event for audit trail.
class ComplianceEvent {
  final String id;
  final ComplianceEventType type;
  final String description;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  const ComplianceEvent({
    required this.id,
    required this.type,
    required this.description,
    this.metadata = const {},
    required this.timestamp,
  });
}

/// Logs compliance-related events for audit trail.
class ComplianceEventLogger {
  static const _tag = 'ComplianceEvents';
  final AppLogger _log = AppLogger(_tag);

  final List<ComplianceEvent> _events = [];
  static const int _maxEvents = 500;

  /// Log a compliance event.
  void log(ComplianceEvent event) {
    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeRange(0, _events.length - _maxEvents);
    }
    _log.debug('Compliance event: ${event.type.name} - ${event.description}');
  }

  /// Get events filtered by type.
  List<ComplianceEvent> getByType(ComplianceEventType type) {
    return _events.where((e) => e.type == type).toList();
  }

  /// Get all events.
  List<ComplianceEvent> get events => List.unmodifiable(_events);

  /// Get events within a time range.
  List<ComplianceEvent> getInRange(DateTime start, DateTime end) {
    return _events
        .where((e) => e.timestamp.isAfter(start) && e.timestamp.isBefore(end))
        .toList();
  }
}

final complianceEventLoggerProvider =
    Provider<ComplianceEventLogger>((ref) {
  return ComplianceEventLogger();
});
