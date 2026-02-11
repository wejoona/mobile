import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Security event severity.
enum SecuritySeverity { info, warning, critical }

/// Analytics event for security monitoring.
class SecurityAnalyticsEvent {
  final String eventType;
  final SecuritySeverity severity;
  final Map<String, dynamic> properties;
  final DateTime timestamp;

  const SecurityAnalyticsEvent({
    required this.eventType,
    required this.severity,
    this.properties = const {},
    required this.timestamp,
  });
}

/// Tracks and aggregates security events for analytics.
class SecurityEventAnalytics {
  static const _tag = 'SecurityAnalytics';
  final AppLogger _log = AppLogger(_tag);

  final List<SecurityAnalyticsEvent> _events = [];
  static const int _maxEvents = 1000;

  /// Track a security event.
  void track({
    required String eventType,
    SecuritySeverity severity = SecuritySeverity.info,
    Map<String, dynamic> properties = const {},
  }) {
    final event = SecurityAnalyticsEvent(
      eventType: eventType,
      severity: severity,
      properties: properties,
      timestamp: DateTime.now(),
    );
    _events.add(event);
    if (_events.length > _maxEvents) {
      _events.removeAt(0);
    }

    if (severity == SecuritySeverity.critical) {
      _log.error('CRITICAL security event: $eventType');
    }
  }

  /// Get event count by type.
  Map<String, int> eventCountsByType() {
    final counts = <String, int>{};
    for (final event in _events) {
      counts[event.eventType] = (counts[event.eventType] ?? 0) + 1;
    }
    return counts;
  }

  /// Get critical events from the last N hours.
  List<SecurityAnalyticsEvent> recentCritical({int hours = 24}) {
    final cutoff = DateTime.now().subtract(Duration(hours: hours));
    return _events
        .where((e) =>
            e.severity == SecuritySeverity.critical &&
            e.timestamp.isAfter(cutoff))
        .toList();
  }

  /// Get all events.
  List<SecurityAnalyticsEvent> get events => List.unmodifiable(_events);
}

final securityEventAnalyticsProvider =
    Provider<SecurityEventAnalytics>((ref) {
  return SecurityEventAnalytics();
});
