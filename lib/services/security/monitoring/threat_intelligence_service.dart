import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Known threat indicator.
class ThreatIndicator {
  final String type;
  final String value;
  final String severity;
  final DateTime lastSeen;

  const ThreatIndicator({
    required this.type,
    required this.value,
    required this.severity,
    required this.lastSeen,
  });
}

/// Fetches and checks against threat intelligence feeds.
class ThreatIntelligenceService {
  static const _tag = 'ThreatIntel';
  final AppLogger _log = AppLogger(_tag);
  final Dio _dio;

  final Set<String> _blockedAddresses = {};
  DateTime? _lastUpdate;

  ThreatIntelligenceService({required Dio dio}) : _dio = dio;

  /// Update threat intelligence data from backend.
  Future<void> update() async {
    try {
      final response = await _dio.get('/security/threat-intel');
      final data = response.data as Map<String, dynamic>;
      final addresses = List<String>.from(data['blockedAddresses'] ?? []);
      _blockedAddresses
        ..clear()
        ..addAll(addresses);
      _lastUpdate = DateTime.now();
      _log.debug('Threat intel updated: ${addresses.length} blocked addresses');
    } catch (e) {
      _log.error('Failed to update threat intelligence', e);
    }
  }

  /// Check if a wallet address is on a blocklist.
  bool isAddressBlocked(String address) {
    return _blockedAddresses.contains(address.toLowerCase());
  }

  /// Check if threat data is stale.
  bool get isStale {
    if (_lastUpdate == null) return true;
    return DateTime.now().difference(_lastUpdate!) > const Duration(hours: 6);
  }
}

final threatIntelligenceServiceProvider =
    Provider<ThreatIntelligenceService>((ref) {
  return ThreatIntelligenceService(dio: Dio());
});
