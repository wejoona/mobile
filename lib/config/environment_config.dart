/// Environment configuration for Korido.
///
/// Values are injected at compile time via --dart-define or
/// --dart-define-from-file.
class EnvironmentConfig {
  const EnvironmentConfig._();

  /// Current environment name.
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  /// Whether this is a production build.
  static bool get isProduction => environment == 'production';

  /// Whether this is a staging build.
  static bool get isStaging => environment == 'staging';

  /// Whether this is a development build.
  static bool get isDevelopment => environment == 'development';

  /// Enable verbose logging in non-production builds.
  static bool get enableLogging => !isProduction;

  /// Enable mock data for development.
  static const bool useMocks = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: false,
  );

  /// Sentry DSN for crash reporting (empty = disabled).
  static const String sentryDsn = String.fromEnvironment(
    'SENTRY_DSN',
    defaultValue: '',
  );

  /// Whether crash reporting is enabled.
  static bool get enableCrashReporting =>
      sentryDsn.isNotEmpty && isProduction;

  /// App version override (for testing).
  static const String versionOverride = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '',
  );
}
