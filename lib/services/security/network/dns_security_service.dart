import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../utils/logger.dart';

/// DNS resolution result with security metadata.
class DnsResolutionResult {
  final String hostname;
  final List<InternetAddress> addresses;
  final bool isSecure;
  final String? warning;
  final Duration resolveTime;

  const DnsResolutionResult({
    required this.hostname,
    required this.addresses,
    required this.isSecure,
    this.warning,
    required this.resolveTime,
  });
}

/// Validates DNS resolution for API endpoints.
///
/// Detects DNS spoofing by verifying resolved addresses against
/// known-good IP ranges and monitoring for resolution anomalies.
class DnsSecurityService {
  static const _tag = 'DnsSecurity';
  final AppLogger _log = AppLogger(_tag);

  /// Known-good IP prefixes for the API backend.
  final List<String> _trustedPrefixes;

  DnsSecurityService({List<String> trustedPrefixes = const []})
      : _trustedPrefixes = trustedPrefixes;

  /// Resolve and validate a hostname.
  Future<DnsResolutionResult> secureResolve(String hostname) async {
    final sw = Stopwatch()..start();
    try {
      final addresses = await InternetAddress.lookup(hostname);
      sw.stop();

      String? warning;
      bool secure = true;

      if (addresses.isEmpty) {
        warning = 'No addresses resolved for $hostname';
        secure = false;
      } else if (_trustedPrefixes.isNotEmpty) {
        final untrusted = addresses.where((a) =>
            !_trustedPrefixes.any((p) => a.address.startsWith(p)));
        if (untrusted.isNotEmpty) {
          warning = 'Untrusted IP resolved: ${untrusted.first.address}';
          secure = false;
        }
      }

      // Suspiciously fast resolution may indicate local poisoning
      if (sw.elapsedMilliseconds < 1) {
        warning = (warning ?? '') + ' Suspiciously fast resolution';
        secure = false;
      }

      if (!secure) {
        _log.error('DNS security warning for $hostname: $warning');
      }

      return DnsResolutionResult(
        hostname: hostname,
        addresses: addresses,
        isSecure: secure,
        warning: warning,
        resolveTime: sw.elapsed,
      );
    } catch (e) {
      sw.stop();
      _log.error('DNS resolution failed for $hostname', e);
      return DnsResolutionResult(
        hostname: hostname,
        addresses: [],
        isSecure: false,
        warning: 'Resolution failed: $e',
        resolveTime: sw.elapsed,
      );
    }
  }
}

final dnsSecurityServiceProvider = Provider<DnsSecurityService>((ref) {
  return DnsSecurityService();
});
