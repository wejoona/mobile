import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/services/security/network/ssl_pinning_manager.dart';
import 'package:usdc_wallet/services/security/network/api_request_signer.dart';
import 'package:usdc_wallet/services/security/network/request_encryptor.dart';
import 'package:usdc_wallet/services/security/network/mitm_detector.dart';
import 'package:usdc_wallet/services/security/network/vpn_proxy_detector.dart';
import 'package:usdc_wallet/services/security/network/network_trust_evaluator.dart';
import 'package:usdc_wallet/services/security/network/connection_monitor.dart';

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
