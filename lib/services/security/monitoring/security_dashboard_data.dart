import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/security/monitoring/security_metrics_collector.dart';
import 'package:usdc_wallet/services/security/monitoring/app_security_score.dart';

/// Aggregates data for the security dashboard UI.
class SecurityDashboardData {
  final int securityScore;
  final int totalIncidents;
  final int activeThreats;
  final Map<String, int> metrics;
  final DateTime lastUpdated;

  const SecurityDashboardData({
    this.securityScore = 100,
    this.totalIncidents = 0,
    this.activeThreats = 0,
    this.metrics = const {},
    required this.lastUpdated,
  });
}

class SecurityDashboardNotifier extends StateNotifier<SecurityDashboardData> {
  static const _tag = 'SecDashboard';
  final AppLogger _log = AppLogger(_tag);

  SecurityDashboardNotifier()
      : super(SecurityDashboardData(lastUpdated: DateTime.now()));

  Future<void> refresh() async {
    _log.debug('Refreshing security dashboard');
    state = SecurityDashboardData(
      securityScore: 95,
      totalIncidents: 0,
      activeThreats: 0,
      lastUpdated: DateTime.now(),
    );
  }
}

final securityDashboardProvider =
    StateNotifierProvider<SecurityDashboardNotifier, SecurityDashboardData>((ref) {
  return SecurityDashboardNotifier();
});
