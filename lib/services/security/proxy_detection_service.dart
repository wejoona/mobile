import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/logger.dart';

/// Service de détection de proxy/VPN.
///
/// Détecte si le trafic réseau passe par un proxy,
/// un VPN ou un tunnel, ce qui pourrait indiquer
/// une interception MITM.
class ProxyDetectionService {
  static const _tag = 'ProxyDetection';
  final AppLogger _log = AppLogger(_tag);

  /// Vérifier la présence d'un proxy système
  Future<ProxyDetectionResult> detectProxy() async {
    final indicators = <String>[];

    // Vérifier les variables d'environnement proxy
    final proxyVars = ['http_proxy', 'https_proxy', 'HTTP_PROXY', 'HTTPS_PROXY'];
    for (final v in proxyVars) {
      final value = Platform.environment[v];
      if (value != null && value.isNotEmpty) {
        indicators.add('Proxy env var set: $v');
      }
    }

    // Vérifier les interfaces réseau VPN courantes
    if (await _checkVpnInterfaces()) {
      indicators.add('VPN interface detected');
    }

    return ProxyDetectionResult(
      proxyDetected: indicators.isNotEmpty,
      indicators: indicators,
      checkedAt: DateTime.now(),
    );
  }

  Future<bool> _checkVpnInterfaces() async {
    try {
      final interfaces = await NetworkInterface.list();
      final vpnPrefixes = ['tun', 'tap', 'ppp', 'ipsec', 'utun'];
      for (final iface in interfaces) {
        for (final prefix in vpnPrefixes) {
          if (iface.name.toLowerCase().startsWith(prefix)) {
            return true;
          }
        }
      }
    } catch (e) {
      _log.error('Failed to check network interfaces', e);
    }
    return false;
  }

  /// Vérifier si le proxy est autorisé pour cette session
  bool isProxyAllowed({required bool isHighRiskTransaction}) {
    // Les transactions à haut risque ne sont pas autorisées via proxy
    return !isHighRiskTransaction;
  }
}

class ProxyDetectionResult {
  final bool proxyDetected;
  final List<String> indicators;
  final DateTime checkedAt;

  const ProxyDetectionResult({
    required this.proxyDetected,
    this.indicators = const [],
    required this.checkedAt,
  });
}

final proxyDetectionProvider = Provider<ProxyDetectionService>((ref) {
  return ProxyDetectionService();
});
