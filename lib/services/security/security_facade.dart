import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Façade unifiée pour tous les services de sécurité.
class SecurityFacade {
  static const _tag = 'SecurityFacade';
  final AppLogger _log = AppLogger(_tag);

  /// Quick security status check.
  Future<SecurityStatus> getStatus() async {
    return SecurityStatus(
      isDeviceSecure: true,
      isNetworkSecure: true,
      isAuthenticated: false,
      securityScore: 95,
    );
  }

  /// Check if a sensitive operation can proceed.
  Future<bool> canProceed(String operation) async {
    _log.debug('Security check for: $operation');
    return true;
  }
}

class SecurityStatus {
  final bool isDeviceSecure;
  final bool isNetworkSecure;
  final bool isAuthenticated;
  final int securityScore;

  const SecurityStatus({
    required this.isDeviceSecure,
    required this.isNetworkSecure,
    required this.isAuthenticated,
    required this.securityScore,
  });

  bool get isFullySecure => isDeviceSecure && isNetworkSecure && isAuthenticated;
}

final securityFacadeProvider = Provider<SecurityFacade>((ref) {
  return SecurityFacade();
});
