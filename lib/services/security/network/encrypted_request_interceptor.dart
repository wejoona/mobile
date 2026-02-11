import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:usdc_wallet/services/security/network/request_encryptor.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Dio interceptor that encrypts request bodies and decrypts responses
/// for endpoints marked as sensitive.
class EncryptedRequestInterceptor extends Interceptor {
  static const _tag = 'EncryptedRequest';
  final AppLogger _log = AppLogger(_tag);
  final RequestEncryptor _encryptor;

  /// Paths requiring payload encryption.
  static const _encryptedPaths = [
    '/wallet/transfer',
    '/wallet/withdraw',
    '/pin/verify',
    '/pin/change',
  ];

  EncryptedRequestInterceptor({required RequestEncryptor encryptor})
      : _encryptor = encryptor;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!_encryptor.hasSessionKey || !_shouldEncrypt(options.path)) {
      handler.next(options);
      return;
    }

    try {
      if (options.data is Map<String, dynamic>) {
        options.data = _encryptor.encryptPayload(
            options.data as Map<String, dynamic>);
        options.headers['X-Encrypted'] = '1';
      }
    } catch (e) {
      _log.error('Request encryption failed', e);
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (!_encryptor.hasSessionKey) {
      handler.next(response);
      return;
    }

    try {
      if (response.data is Map<String, dynamic> &&
          (response.data as Map).containsKey('encrypted')) {
        response.data = _encryptor.decryptPayload(
            response.data as Map<String, dynamic>);
      }
    } catch (e) {
      _log.error('Response decryption failed', e);
    }
    handler.next(response);
  }

  bool _shouldEncrypt(String path) {
    return _encryptedPaths.any((p) => path.contains(p));
  }
}
