import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_request_signer.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Dio interceptor that signs outgoing requests using [ApiRequestSigner].
///
/// Adds headers:
/// - X-Request-Timestamp: milliseconds since epoch
/// - X-Request-Signature: HMAC signature of the canonical request
class RequestSigningInterceptor extends Interceptor {
  final ApiRequestSigner _signer;
  static const _tag = 'RequestSigning';
  final AppLogger _log = AppLogger(_tag);

  RequestSigningInterceptor({required ApiRequestSigner signer})
      : _signer = signer;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String? bodyHash;
      if (options.data != null) {
        final body = options.data is String
            ? options.data as String
            : jsonEncode(options.data);
        bodyHash = _signer.computeBodyHash(body);
      }

      final signature = _signer.sign(
        method: options.method,
        path: options.path,
        timestampMs: timestamp,
        bodyHash: bodyHash,
      );

      options.headers['X-Request-Timestamp'] = timestamp.toString();
      options.headers['X-Request-Signature'] = signature;
    } catch (e) {
      _log.error('Request signing failed', e);
    }
    handler.next(options);
  }
}
