// ignore_for_file: do_not_use_environment

import 'package:usdc_wallet/config/environment_config.dart';

/// API-specific configuration for Korido.
class ApiConfiguration {
  const ApiConfiguration._();

  /// Base API URL.
  static const String _envApiUrl = String.fromEnvironment('API_URL');

  static const String _devUrl = 'http://127.0.0.1:3401/api/v1';
  static const String _stagingUrl = 'https://api.joonalabs.com/korido/v1';
  static const String _prodUrl = 'https://korido-api.joonapay.com/api/v1';

  /// Resolved API base URL.
  static String get baseUrl {
    if (_envApiUrl.isNotEmpty) {
      return _envApiUrl;
    }
    if (EnvironmentConfig.isProduction) {
      return _prodUrl;
    }
    if (EnvironmentConfig.isStaging) {
      return _stagingUrl;
    }
    return _devUrl;
  }

  /// Socket.IO namespace URL for real-time updates.
  ///
  /// The API base URL includes `/api/v1`, but the NestJS Socket.IO gateway is
  /// mounted at the host-level `/ws` namespace.
  static String get wsUrl {
    final uri = Uri.parse(baseUrl);
    return Uri(
      scheme: uri.scheme,
      userInfo: uri.userInfo,
      host: uri.host,
      port: uri.hasPort ? uri.port : 0,
      path: '/ws',
    ).toString();
  }

  /// Request timeout in milliseconds.
  static const int connectTimeout = 15000;

  /// Response timeout in milliseconds.
  static const int receiveTimeout = 30000;

  /// Maximum retry attempts for failed requests.
  static const int maxRetries = 3;

  /// Cache TTL in seconds for list endpoints.
  static const int defaultCacheTtl = 300;
}
