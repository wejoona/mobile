import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:usdc_wallet/core/constants/api_endpoints.dart';
import 'package:usdc_wallet/services/security/client_risk_score_service.dart';
import 'package:usdc_wallet/services/security/device_fingerprint_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Dio interceptor that attaches security headers to sensitive API calls.
///
/// Headers added:
/// - `X-Device-Id` — stable device identifier
/// - `X-Device-Fingerprint` — SHA-256 hash of device properties
/// - `X-Risk-Score` — client-side risk score (0.0–1.0)
/// - `X-Risk-Session` — session risk token from POST /risk/session
///
/// These allow the backend to correlate requests per device and flag
/// anomalous behaviour even before server-side risk evaluation runs.
class SecurityHeadersInterceptor extends Interceptor {
  final DeviceFingerprintService _fingerprintService;
  final ClientRiskScoreService _riskScoreService;
  String? sessionRiskToken;

  /// Paths that are considered sensitive and receive full headers.
  static const _sensitivePaths = [
    '/wallet/cash-out/mobile-money',
    '/deposits/',
    '/step-up/',
    '/wallet/transfer',
    '/wallet/deposit',
    '/auth/login',
    '/auth/verify-otp',
    '/auth/register',
    '/devices',
    ApiEndpoints.userPinPrefix,
    '/risk/',
  ];

  SecurityHeadersInterceptor({
    required DeviceFingerprintService fingerprintService,
    required ClientRiskScoreService riskScoreService,
  }) : _fingerprintService = fingerprintService,
       _riskScoreService = riskScoreService;

  bool _collecting = false;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final headers = await buildHeadersForPath(
        options.path,
        requestData: options.data,
      );
      for (final entry in headers.entries) {
        if (entry.key == 'User-Agent' &&
            options.headers.containsKey('User-Agent')) {
          continue;
        }
        options.headers[entry.key] = entry.value;
      }
    } catch (e) {
      // Never block a request because of header enrichment failure
      AppLogger(
        'SecurityHeaders',
      ).error('Failed to attach security headers', e);
    }

    handler.next(options);
  }

  /// Build the same security headers for requests made by temporary Dio
  /// clients, such as token refresh retries that do not pass through the
  /// normal interceptor chain.
  Future<Map<String, String>> buildHeadersForPath(
    String path, {
    Object? requestData,
  }) async {
    // Eagerly collect fingerprint on first request (cached after that).
    if (_fingerprintService.cachedDeviceId == null && !_collecting) {
      _collecting = true;
      try {
        await _fingerprintService.collect();
      } finally {
        _collecting = false;
      }
    }

    final headers = <String, String>{};
    final deviceId = _fingerprintService.cachedDeviceId;
    final fingerprint = _fingerprintService.cachedFingerprintHash;
    final device = _fingerprintService.cachedFingerprint;

    if (deviceId != null) {
      headers['X-Device-Id'] = deviceId;
    }
    if (fingerprint != null) {
      headers['X-Device-Fingerprint'] = fingerprint;
    }
    if (device != null) {
      headers['User-Agent'] =
          'Korido/${device.appVersion} '
          '(${device.os}; ${device.model ?? device.platform}; '
          '${device.osVersion ?? 'unknown'})';
      headers['X-Device-Platform'] = device.platform;
      headers['X-Device-Physical'] = device.isPhysicalDevice.toString();
      headers['X-Device-Compromised'] = device.isCompromised.toString();
      headers['X-Biometrics-Available'] = device.biometricsAvailable.toString();
    }
    if (sessionRiskToken != null) {
      headers['X-Risk-Session'] = sessionRiskToken!;
    }
    if (_isSensitive(path)) {
      final action = _inferAction(path, requestData);
      final score = await _riskScoreService.calculateRiskScore(action: action);
      headers['X-Risk-Score'] = score.toStringAsFixed(2);
    }

    return headers;
  }

  bool _isSensitive(String path) {
    return _sensitivePaths.any((p) => path.contains(p));
  }

  RiskAction _inferAction(String path, Object? requestData) {
    if (path.contains('/step-up/operation')) {
      final operation = _operationFromRequestData(requestData);
      if (operation == 'account_recovery') {
        return RiskAction.accountRecovery;
      }
      if (operation == 'delete_account' || operation == 'export_keys') {
        return RiskAction.largeTransaction;
      }
    }
    if (path.contains('login') ||
        path.contains('register') ||
        path.contains('verify-otp')) {
      return RiskAction.login;
    }
    if (path.contains('withdraw')) return RiskAction.withdrawal;
    if (path.contains('transfer')) return RiskAction.transfer;
    return RiskAction.transfer;
  }

  String? _operationFromRequestData(Object? data) {
    if (data is Map) {
      return data['operation']?.toString();
    }
    return null;
  }
}

/// Provider for SecurityHeadersInterceptor (singleton so token can be set)
final securityHeadersInterceptorProvider = Provider<SecurityHeadersInterceptor>(
  (ref) {
    return SecurityHeadersInterceptor(
      fingerprintService: ref.read(deviceFingerprintServiceProvider),
      riskScoreService: ref.read(clientRiskScoreServiceProvider),
    );
  },
);
