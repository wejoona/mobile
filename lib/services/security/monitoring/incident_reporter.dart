import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Severity levels for security incidents.
enum IncidentSeverity { low, medium, high, critical }

/// Reports security incidents to the backend.
class IncidentReporter {
  static const _tag = 'IncidentReport';
  final AppLogger _log = AppLogger(_tag);
  final List<SecurityIncident> _incidents = [];

  /// Report a security incident.
  Future<void> report(SecurityIncident incident) async {
    _incidents.add(incident);
    _log.warn('Security incident [${incident.severity.name}]: ${incident.title}');
    // Would send to backend security endpoint
  }

  /// Get recent incidents.
  List<SecurityIncident> getRecent({int limit = 20}) {
    return _incidents.reversed.take(limit).toList();
  }

  int get criticalCount =>
      _incidents.where((i) => i.severity == IncidentSeverity.critical).length;
}

class SecurityIncident {
  final String id;
  final String title;
  final String description;
  final IncidentSeverity severity;
  final DateTime timestamp;
  final Map<String, dynamic> context;

  SecurityIncident({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    this.context = const {},
  }) : timestamp = DateTime.now();
}

final incidentReporterProvider = Provider<IncidentReporter>((ref) {
  return IncidentReporter();
});
