import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/utils/logger.dart';
import 'package:usdc_wallet/services/security/network/ssl_pinning_manager.dart';

/// Wraps HttpClient with all security layers applied.
class SecureHttpClient {
  static const _tag = 'SecureHttp';
  final AppLogger _log = AppLogger(_tag);
  final SslPinningManager _pinningManager;
  late final HttpClient _client;

  SecureHttpClient(this._pinningManager) {
    _client = _pinningManager.createPinnedClient();
    _client.connectionTimeout = const Duration(seconds: 30);
  }

  HttpClient get client => _client;

  void close() {
    _client.close();
    _log.debug('Secure HTTP client closed');
  }
}

final secureHttpClientProvider = Provider<SecureHttpClient>((ref) {
  final pinning = ref.read(sslPinningManagerProvider);
  final client = SecureHttpClient(pinning);
  ref.onDispose(client.close);
  return client;
});
