/// Dio interceptor for JWE encryption of sensitive API requests.
///
/// Automatically encrypts request bodies for endpoints classified as
/// sensitive (transfers, PIN ops, withdrawals, deposits).
/// Non-sensitive endpoints pass through unmodified.
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/services/security/jwe/jwe_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

final _log = AppLogger('JweInterceptor');

/// Paths that require JWE encryption of request bodies.
const _sensitivePathPatterns = [
  '/user/pin/',        // PIN set, verify, change, reset
  '/wallet/pin/',      // Wallet PIN operations
  '/wallet/deposit',   // Deposit initiation
  '/wallet/transfer/', // Internal + external transfers
  '/wallet/withdraw',  // Withdrawals
];

class JweInterceptor extends Interceptor {
  final JweService _jweService;
  bool _enabled = true;

  JweInterceptor(this._jweService);

  /// Enable/disable JWE encryption (useful for testing).
  set enabled(bool value) => _enabled = value;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Only encrypt POST/PUT/PATCH with body on sensitive endpoints
    if (!_enabled ||
        options.data == null ||
        !_isMutatingMethod(options.method) ||
        !_isSensitivePath(options.path)) {
      return handler.next(options);
    }

    try {
      // Get the payload as Map
      Map<String, dynamic> payload;
      if (options.data is Map<String, dynamic>) {
        payload = options.data as Map<String, dynamic>;
      } else if (options.data is String) {
        payload = jsonDecode(options.data as String) as Map<String, dynamic>;
      } else {
        return handler.next(options);
      }

      // Encrypt as JWE
      final jweToken = await _jweService.encrypt(payload);

      // Replace body with JWE envelope
      options.data = {'jwe': jweToken};
      options.headers['X-Content-Encrypted'] = 'JWE';

      _log.debug('Encrypted request body for ${options.path}');
    } catch (e) {
      _log.error('JWE encryption failed, sending plaintext', e);
      // Graceful degradation: send unencrypted rather than fail
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If server says "re-fetch key", invalidate cache
    if (err.response?.statusCode == 400) {
      final body = err.response?.data;
      if (body is Map && body['message']?.toString().contains('re-fetch') == true) {
        _jweService.invalidateKey();
        _log.info('Server key invalidated, will re-fetch on next request');
      }
    }
    handler.next(err);
  }

  bool _isMutatingMethod(String method) {
    final m = method.toUpperCase();
    return m == 'POST' || m == 'PUT' || m == 'PATCH';
  }

  bool _isSensitivePath(String path) {
    return _sensitivePathPatterns.any((pattern) => path.contains(pattern));
  }
}
