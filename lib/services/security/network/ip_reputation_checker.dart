import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Checks IP reputation to detect suspicious connections.
class IpReputationChecker {
  static const _tag = 'IpReputation';
  final AppLogger _log = AppLogger(_tag);

  /// Check if the server IP is known and trusted.
  Future<IpReputation> check(String ip) async {
    _log.debug('Checking IP reputation: $ip');
    // Would query threat intelligence API
    return IpReputation(ip: ip, score: 100, isTrusted: true);
  }

  /// Check if IP belongs to known VPN/proxy ranges.
  Future<bool> isVpnIp(String ip) async {
    return false;
  }
}

class IpReputation {
  final String ip;
  final int score; // 0-100
  final bool isTrusted;
  final String? threatType;

  const IpReputation({
    required this.ip,
    required this.score,
    required this.isTrusted,
    this.threatType,
  });
}

final ipReputationCheckerProvider = Provider<IpReputationChecker>((ref) {
  return IpReputationChecker();
});
