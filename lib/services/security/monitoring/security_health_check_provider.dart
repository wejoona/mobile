import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/security/network/network_trust_evaluator.dart';
import 'package:usdc_wallet/services/security/auth/brute_force_lockout_service.dart';
import 'package:usdc_wallet/services/security/auth/biometric_reenrollment_detector.dart';

/// Individual health check result.
class HealthCheckItem {
  final String name;
  final bool passed;
  final String? detail;

  const HealthCheckItem({
    required this.name,
    required this.passed,
    this.detail,
  });
}

/// Overall security health status.
class SecurityHealthStatus {
  final List<HealthCheckItem> checks;
  final int passedCount;
  final int totalCount;
  final DateTime checkedAt;

  SecurityHealthStatus({required this.checks, required this.checkedAt})
      : passedCount = checks.where((c) => c.passed).length,
        totalCount = checks.length;

  double get healthPercentage =>
      totalCount == 0 ? 100 : (passedCount / totalCount) * 100;

  bool get isHealthy => passedCount == totalCount;
}

/// Performs comprehensive security health checks.
class SecurityHealthCheckProvider {
  static const _tag = 'SecurityHealth';
  final AppLogger _log = AppLogger(_tag);

  final NetworkTrustEvaluator _networkEvaluator;
  final BruteForceLockoutService _lockoutService;
  final BiometricReenrollmentDetector _biometricDetector;

  SecurityHealthCheckProvider({
    required NetworkTrustEvaluator networkEvaluator,
    required BruteForceLockoutService lockoutService,
    required BiometricReenrollmentDetector biometricDetector,
  })  : _networkEvaluator = networkEvaluator,
        _lockoutService = lockoutService,
        _biometricDetector = biometricDetector;

  /// Run all security health checks.
  Future<SecurityHealthStatus> runChecks(String apiHost) async {
    final checks = <HealthCheckItem>[];

    // Network trust
    try {
      final network = await _networkEvaluator.evaluate(apiHost);
      checks.add(HealthCheckItem(
        name: 'Securite reseau',
        passed: network.level == NetworkTrustLevel.trusted,
        detail: 'Niveau: ${network.level.name}',
      ));
    } catch (e) {
      checks.add(HealthCheckItem(
        name: 'Securite reseau',
        passed: false,
        detail: 'Verification echouee',
      ));
    }

    // Brute force status
    final lockout = await _lockoutService.getState();
    checks.add(HealthCheckItem(
      name: 'Protection anti-bruteforce',
      passed: !lockout.isLocked && lockout.failedAttempts < 3,
      detail: '${lockout.failedAttempts} tentatives echouees',
    ));

    // Biometric integrity
    final biometricChanged = await _biometricDetector.hasEnrollmentChanged();
    checks.add(HealthCheckItem(
      name: 'Integrite biometrique',
      passed: !biometricChanged,
      detail: biometricChanged ? 'Changement detecte' : 'OK',
    ));

    final status = SecurityHealthStatus(
      checks: checks,
      checkedAt: DateTime.now(),
    );

    _log.debug('Health check: ${status.passedCount}/${status.totalCount} passed');
    return status;
  }
}

final securityHealthCheckProvider =
    Provider<SecurityHealthCheckProvider>((ref) {
  return SecurityHealthCheckProvider(
    networkEvaluator: ref.watch(networkTrustEvaluatorProvider),
    lockoutService: ref.watch(bruteForceLockoutServiceProvider),
    biometricDetector: ref.watch(biometricReenrollmentDetectorProvider),
  );
});
