import 'package:dio/dio.dart';

import 'client_risk_score_service.dart';
import 'device_fingerprint_service.dart';
import '../../utils/logger.dart';

/// Dio interceptor that attaches security headers to sensitive API calls.
///
/// Headers added:
/// - `X-Device-Id` — stable device identifier
/// - `X-Device-Fingerprint` — SHA-256 hash of device properties
/// - `X-Risk-Score` — client-side risk score (0.0–1.0)
///
/// These allow the backend to correlate requests per device and flag
/// anomalous behaviour even before server-side risk evaluation runs.
class SecurityHeadersInterceptor extends Interceptor {
  final DeviceFingerprintService _fingerprintService;
  final ClientRiskScoreService _riskScoreService;

  /// Paths that are considered sensitive and receive full headers.
  static const _sensitivePaths = [
    '/transfers/',
    '/step-up/',
    '/wallet/transfer',
    '/wallet/withdraw',
    '/auth/login',
    '/auth/verify-otp',
    '/auth/register',
    '/devices',
    '/pin/',
    '/risk/',
  ];

  SecurityHeadersInterceptor({
    required DeviceFingerprintService fingerprintService,
    required ClientRiskScoreService riskScoreService,
  })  : _fingerprintService = fingerprintService,
        _riskScoreService = riskScoreService;

  bool _collecting = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Eagerly collect fingerprint on first request (cached after that)
      if (_fingerprintService.cachedDeviceId == null && !_collecting) {
        _collecting = true;
        try {
          await _fingerprintService.collect();
        } finally {
          _collecting = false;
        }
      }

      final deviceId = _fingerprintService.cachedDeviceId;
      final fingerprint = _fingerprintService.cachedFingerprintHash;

      if (deviceId != null) {
        options.headers['X-Device-Id'] = deviceId;
      }
      if (fingerprint != null) {
        options.headers['X-Device-Fingerprint'] = fingerprint;
      }

      // Attach risk score only on sensitive endpoints to avoid overhead
      if (_isSensitive(options.path)) {
        final action = _inferAction(options.path);
        final score = await _riskScoreService.calculateRiskScore(action: action);
        options.headers['X-Risk-Score'] = score.toStringAsFixed(2);
      }
    } catch (e) {
      // Never block a request because of header enrichment failure
      AppLogger('SecurityHeaders').error('Failed to attach security headers', e);
    }

    handler.next(options);
  }

  bool _isSensitive(String path) {
    return _sensitivePaths.any((p) => path.contains(p));
  }

  RiskAction _inferAction(String path) {
    if (path.contains('login') || path.contains('register') || path.contains('verify-otp')) {
      return RiskAction.login;
    }
    if (path.contains('withdraw')) return RiskAction.withdrawal;
    if (path.contains('transfer')) return RiskAction.transfer;
    return RiskAction.transfer;
  }
}
