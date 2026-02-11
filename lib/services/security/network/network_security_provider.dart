import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ssl_pinning_manager.dart';
import 'api_request_signer.dart';
import 'request_encryptor.dart';
import 'mitm_detector.dart';
import 'vpn_proxy_detector.dart';
import 'network_trust_evaluator.dart';
import 'connection_monitor.dart';

/// Aggregate provider exposing all network security services.
///
/// Use this when you need access to the full network security stack
/// without importing each provider individually.
class NetworkSecurityServices {
  final SslPinningManager sslPinning;
  final ApiRequestSigner requestSigner;
  final RequestEncryptor requestEncryptor;
  final MitmDetector mitmDetector;
  final VpnProxyDetector vpnProxyDetector;
  final NetworkTrustEvaluator trustEvaluator;
  final ConnectionMonitor connectionMonitor;

  const NetworkSecurityServices({
    required this.sslPinning,
    required this.requestSigner,
    required this.requestEncryptor,
    required this.mitmDetector,
    required this.vpnProxyDetector,
    required this.trustEvaluator,
    required this.connectionMonitor,
  });
}

final networkSecurityServicesProvider =
    Provider<NetworkSecurityServices>((ref) {
  return NetworkSecurityServices(
    sslPinning: ref.watch(sslPinningManagerProvider),
    requestSigner: ref.watch(apiRequestSignerProvider),
    requestEncryptor: ref.watch(requestEncryptorProvider),
    mitmDetector: ref.watch(mitmDetectorProvider),
    vpnProxyDetector: ref.watch(vpnProxyDetectorProvider),
    trustEvaluator: ref.watch(networkTrustEvaluatorProvider),
    connectionMonitor: ref.watch(connectionMonitorProvider),
  );
});
