import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'vpn_proxy_detector.dart';
import 'mitm_detector.dart';
import 'dns_security_service.dart';

/// Overall network trust level.
enum NetworkTrustLevel { trusted, cautious, untrusted }

/// Aggregated network trust evaluation.
class NetworkTrustResult {
  final NetworkTrustLevel level;
  final double score;
  final List<String> findings;
  final DateTime evaluatedAt;

  const NetworkTrustResult({
    required this.level,
    required this.score,
    required this.findings,
    required this.evaluatedAt,
  });
}

/// Evaluates overall network trustworthiness by combining
/// VPN/proxy, MITM, and DNS security signals.
class NetworkTrustEvaluator {
  static const _tag = 'NetworkTrust';
  final AppLogger _log = AppLogger(_tag);

  final VpnProxyDetector _vpnDetector;
  final MitmDetector _mitmDetector;
  final DnsSecurityService _dnsService;

  NetworkTrustEvaluator({
    required VpnProxyDetector vpnDetector,
    required MitmDetector mitmDetector,
    required DnsSecurityService dnsService,
  })  : _vpnDetector = vpnDetector,
        _mitmDetector = mitmDetector,
        _dnsService = dnsService;

  /// Evaluate network trust for connecting to [apiHost].
  Future<NetworkTrustResult> evaluate(String apiHost) async {
    double score = 1.0;
    final findings = <String>[];

    // VPN/Proxy check
    final vpnStatus = await _vpnDetector.check();
    if (vpnStatus.vpnDetected) {
      score -= 0.3;
      findings.add('VPN connection active');
    }
    if (vpnStatus.proxyDetected) {
      score -= 0.2;
      findings.add('Proxy configured');
    }

    // MITM check
    final mitmResult = await _mitmDetector.detect(targetHost: apiHost);
    if (mitmResult.isSuspicious) {
      score -= 0.4;
      findings.addAll(mitmResult.indicators);
    }

    // DNS check
    final dnsResult = await _dnsService.secureResolve(apiHost);
    if (!dnsResult.isSecure) {
      score -= 0.3;
      if (dnsResult.warning != null) findings.add(dnsResult.warning!);
    }

    score = score.clamp(0.0, 1.0);
    final level = score >= 0.7
        ? NetworkTrustLevel.trusted
        : score >= 0.4
            ? NetworkTrustLevel.cautious
            : NetworkTrustLevel.untrusted;

    _log.debug('Network trust: $level (score: ${score.toStringAsFixed(2)})');

    return NetworkTrustResult(
      level: level,
      score: score,
      findings: findings,
      evaluatedAt: DateTime.now(),
    );
  }
}

final networkTrustEvaluatorProvider = Provider<NetworkTrustEvaluator>((ref) {
  return NetworkTrustEvaluator(
    vpnDetector: ref.watch(vpnProxyDetectorProvider),
    mitmDetector: ref.watch(mitmDetectorProvider),
    dnsService: ref.watch(dnsSecurityServiceProvider),
  );
});
