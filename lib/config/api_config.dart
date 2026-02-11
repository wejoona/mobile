import 'package:usdc_wallet/config/environment_config.dart';

/// API-specific configuration for Korido.
class ApiConfiguration {
  const ApiConfiguration._();

  /// Base API URL.
  static const String _envApiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: '',
  );

  static const String _devUrl =
      'https://usdc-wallet-api.wejoona.com/api/v1';
  static const String _stagingUrl =
      'https://staging-api.korido.app/api/v1';
  static const String _prodUrl =
      'https://api.korido.app/api/v1';

  /// Resolved API base URL.
  static String get baseUrl {
    if (_envApiUrl.isNotEmpty) return _envApiUrl;
    if (EnvironmentConfig.isProduction) return _prodUrl;
    if (EnvironmentConfig.isStaging) return _stagingUrl;
    return _devUrl;
  }

  /// WebSocket URL for real-time updates.
  static String get wsUrl => baseUrl.replaceFirst('http', 'ws');

  /// Request timeout in milliseconds.
  static const int connectTimeout = 15000;

  /// Response timeout in milliseconds.
  static const int receiveTimeout = 30000;

  /// Maximum retry attempts for failed requests.
  static const int maxRetries = 3;

  /// Cache TTL in seconds for list endpoints.
  static const int defaultCacheTtl = 300;
}
