import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Manages data retention policies per BCEAO requirements.
class DataRetentionManager {
  static const _tag = 'DataRetention';
  final AppLogger _log = AppLogger(_tag);

  /// Check if data should be retained or purged.
  bool shouldRetain(String dataType, DateTime createdAt) {
    final retentionDays = _retentionPeriod(dataType);
    return DateTime.now().difference(createdAt) < Duration(days: retentionDays);
  }

  int _retentionPeriod(String dataType) {
    switch (dataType) {
      case 'transaction': return 3650; // 10 years per BCEAO
      case 'audit_log': return 1825; // 5 years
      case 'session': return 90;
      case 'notification': return 365;
      default: return 365;
    }
  }

  /// Get list of data types due for purging.
  List<String> getDataDueForPurge(Map<String, DateTime> dataCreationDates) {
    return dataCreationDates.entries
        .where((e) => !shouldRetain(e.key, e.value))
        .map((e) => e.key)
        .toList();
  }
}

final dataRetentionManagerProvider = Provider<DataRetentionManager>((ref) {
  return DataRetentionManager();
});
