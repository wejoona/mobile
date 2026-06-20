// ignore_for_file: do_not_use_environment

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

  /// Opt into debug/info logs while developing.
  static bool get verboseLogs => _verboseLogs;

  static const bool _verboseLogs = bool.fromEnvironment('VERBOSE_LOGS');

  /// Skip the app lock during debug sessions.
  static bool get debugSkipPin => _debugSkipPin.isNotEmpty;

  static const String _debugSkipPin = String.fromEnvironment('DEBUG_SKIP_PIN');

  /// Access token injected for simulator dogfood verification.
  static const String debugToken = String.fromEnvironment('DEBUG_TOKEN');

  /// Phone number paired with [debugToken] for simulator verification.
  static const String debugPhone = String.fromEnvironment('DEBUG_PHONE');

  /// Show simulator-only OTP helpers during explicit dogfood debug runs.
  static bool get showDevOtpShortcut => isDevelopment && _showDevOtpShortcut;

  static const bool _showDevOtpShortcut = bool.fromEnvironment('SHOW_DEV_OTP');

  /// Enable mock data for local development only.
  static bool get useMocks => isDevelopment && _useMocks;

  static const bool _useMocks = bool.fromEnvironment('USE_MOCKS');

  /// Sentry DSN for crash reporting (empty = disabled).
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  /// Whether crash reporting is enabled.
  static bool get enableCrashReporting =>
      sentryDsn.isNotEmpty && (isProduction || isStaging);

  /// App version override (for testing).
  static const String versionOverride = String.fromEnvironment('APP_VERSION');
}
