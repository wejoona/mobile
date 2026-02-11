import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Result of VPN/proxy detection.
class VpnProxyStatus {
  final bool vpnDetected;
  final bool proxyDetected;
  final List<String> activeInterfaces;
  final DateTime checkedAt;

  const VpnProxyStatus({
    required this.vpnDetected,
    required this.proxyDetected,
    required this.activeInterfaces,
    required this.checkedAt,
  });

  bool get isClean => !vpnDetected && !proxyDetected;
}

/// Detects active VPN connections and proxy configurations.
///
/// Some high-risk operations (withdrawals, large transfers) may be
/// restricted when a VPN or proxy is detected to reduce fraud risk.
class VpnProxyDetector {
  static const _tag = 'VpnProxyDetector';
  final AppLogger _log = AppLogger(_tag);

  /// Known VPN interface name prefixes.
  static const _vpnInterfaces = ['tun', 'tap', 'ppp', 'ipsec', 'utun', 'wg'];

  /// Check for active VPN and proxy.
  Future<VpnProxyStatus> check() async {
    final interfaces = <String>[];
    bool vpn = false;
    bool proxy = false;

    try {
      final netInterfaces = await NetworkInterface.list();
      for (final ni in netInterfaces) {
        interfaces.add(ni.name);
        if (_vpnInterfaces.any((prefix) =>
            ni.name.toLowerCase().startsWith(prefix))) {
          vpn = true;
          _log.debug('VPN interface detected: ${ni.name}');
        }
      }
    } catch (e) {
      _log.error('Failed to enumerate network interfaces', e);
    }

    // Check environment proxy settings
    try {
      final env = Platform.environment;
      if (env['http_proxy'] != null ||
          env['https_proxy'] != null ||
          env['HTTP_PROXY'] != null ||
          env['HTTPS_PROXY'] != null) {
        proxy = true;
        _log.debug('HTTP proxy environment variable detected');
      }
    } catch (_) {}

    return VpnProxyStatus(
      vpnDetected: vpn,
      proxyDetected: proxy,
      activeInterfaces: interfaces,
      checkedAt: DateTime.now(),
    );
  }
}

final vpnProxyDetectorProvider = Provider<VpnProxyDetector>((ref) {
  return VpnProxyDetector();
});
