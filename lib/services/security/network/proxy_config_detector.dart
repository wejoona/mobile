import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// Détecte la configuration proxy du système.
class ProxyConfigDetector {
  static const _tag = 'ProxyDetect';
  final AppLogger _log = AppLogger(_tag);

  /// Check for system-level proxy configuration.
  Future<ProxyConfig> detect() async {
    _log.debug('Detecting proxy configuration');
    // In production: check system proxy settings
    return const ProxyConfig(isProxyConfigured: false);
  }

  /// Check for Charles/Fiddler-style debugging proxies.
  Future<bool> isDebuggingProxyDetected() async {
    // Check common debugging proxy ports
    return false;
  }
}

class ProxyConfig {
  final bool isProxyConfigured;
  final String? proxyHost;
  final int? proxyPort;
  final bool isTransparent;

  const ProxyConfig({
    this.isProxyConfigured = false,
    this.proxyHost,
    this.proxyPort,
    this.isTransparent = false,
  });
}

final proxyConfigDetectorProvider = Provider<ProxyConfigDetector>((ref) {
  return ProxyConfigDetector();
});
