import 'package:usdc_wallet/lib/services/security/network/network_trust_evaluator.dart';
import 'package:usdc_wallet/lib/services/security/network/vpn_proxy_detector.dart';
import 'package:usdc_wallet/lib/services/security/network/mitm_detector.dart';
import 'package:usdc_wallet/lib/services/security/auth/brute_force_lockout_service.dart';
import 'package:usdc_wallet/lib/services/security/auth/mfa_provider.dart';

/// Mock network trust evaluator for testing.
class MockNetworkTrustEvaluator extends NetworkTrustEvaluator {
  final NetworkTrustLevel _fixedLevel;

  MockNetworkTrustEvaluator({
    NetworkTrustLevel level = NetworkTrustLevel.trusted,
  })  : _fixedLevel = level,
        super(
          vpnDetector: _MockVpnDetector(),
          mitmDetector: _MockMitmDetector(),
          dnsService: _MockDnsService(),
        );

  @override
  Future<NetworkTrustResult> evaluate(String apiHost) async {
    return NetworkTrustResult(
      level: _fixedLevel,
      score: _fixedLevel == NetworkTrustLevel.trusted ? 1.0 : 0.3,
      findings: [],
      evaluatedAt: DateTime.now(),
    );
  }
}

class _MockVpnDetector extends VpnProxyDetector {
  @override
  Future<VpnProxyStatus> check() async {
    return VpnProxyStatus(
      vpnDetected: false,
      proxyDetected: false,
      activeInterfaces: [],
      checkedAt: DateTime.now(),
    );
  }
}

class _MockMitmDetector extends MitmDetector {
  @override
  Future<MitmDetectionResult> detect({required String targetHost}) async {
    return MitmDetectionResult(
      isSuspicious: false,
      indicators: [],
      checkedAt: DateTime.now(),
    );
  }
}

class _MockDnsService {}

/// Mock brute force service that never locks.
class MockBruteForceLockoutService extends BruteForceLockoutService {
  @override
  Future<LockoutState> getState() async {
    return const LockoutState(failedAttempts: 0);
  }

  @override
  Future<LockoutState> recordFailure() async {
    return const LockoutState(failedAttempts: 1);
  }

  @override
  Future<void> reset() async {}
}
