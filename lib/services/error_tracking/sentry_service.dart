import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:usdc_wallet/utils/logger.dart';

/// Provider for [SentryService].
final sentryServiceProvider = Provider<SentryService>((ref) {
  return SentryService();
});

/// Sentry Error Tracking Service
///
/// Initializes Sentry SDK, reports unhandled exceptions,
/// and adds navigation breadcrumbs.
class SentryService {
  static final _logger = AppLogger('Sentry');

  /// Korido mobile Sentry DSN (self-hosted).
  static const _defaultDsn = 'https://d68989681327f488d5cb348626e66356@sentry.wejoona.com/3';

  /// Whether Sentry has been initialized.
  bool _initialized = false;

  bool get isInitialized => _initialized;

  /// Initialize Sentry and run the app inside `SentryFlutter.init`.
  ///
  /// [appRunner] is the function that calls `runApp(...)`.
  /// [dsn] overrides the default placeholder DSN.
  /// [environment] sets the Sentry environment tag (e.g. 'dev', 'prod').
  Future<void> initializeAndRunApp({
    required AppRunner appRunner,
    String? dsn,
    String environment = 'dev',
  }) async {
    final sentryDsn = dsn ?? const String.fromEnvironment(
      'SENTRY_DSN',
      defaultValue: _defaultDsn,
    );

    // Skip initialization if DSN is empty or placeholder in debug mode
    if (sentryDsn.isEmpty) {
      _logger.debug('Sentry DSN is empty — skipping initialization');
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = 0.2;
        options.environment = environment;
        options.debug = kDebugMode;
        options.sendDefaultPii = false;
        options.attachStacktrace = true;

        // Navigation breadcrumbs are added via SentryNavigatorObserver in the app's navigatorObservers
      },
      appRunner: appRunner,
    );

    _initialized = true;
    _logger.debug('Sentry initialized (env: $environment)');
  }

  /// Returns a [NavigatorObserver] that records navigation breadcrumbs.
  static NavigatorObserver get navigatorObserver =>
      SentryNavigatorObserver();

  /// Report an exception to Sentry.
  Future<void> captureException(
    dynamic exception, {
    StackTrace? stackTrace,
    String? reason,
    bool fatal = false,
  }) async {
    if (!_initialized) return;

    try {
      await Sentry.captureException(
        exception,
        stackTrace: stackTrace,
        hint: reason != null ? Hint.withMap({'reason': reason}) : null,
      );

      if (kDebugMode) {
        _logger.debug('Exception captured: $exception');
      }
    } catch (e) {
      _logger.debug('Failed to capture exception: $e');
    }
  }

  /// Handle a [FlutterErrorDetails] (for use with `FlutterError.onError`).
  Future<void> captureFlutterError(FlutterErrorDetails details) async {
    if (!_initialized) {
      FlutterError.presentError(details);
      return;
    }

    await Sentry.captureException(
      details.exception,
      stackTrace: details.stack,
    );

    if (kDebugMode) {
      FlutterError.presentError(details);
    }
  }

  /// Add a breadcrumb for context.
  Future<void> addBreadcrumb({
    required String message,
    String? category,
    Map<String, dynamic>? data,
    SentryLevel level = SentryLevel.info,
  }) async {
    if (!_initialized) return;

    await Sentry.addBreadcrumb(
      Breadcrumb(
        message: message,
        category: category,
        data: data,
        level: level,
      ),
    );
  }

  /// Set the current user for Sentry context.
  Future<void> setUser({String? id, String? email, String? username}) async {
    if (!_initialized) return;

    await Sentry.configureScope((scope) {
      if (id != null || email != null || username != null) {
        scope.setUser(SentryUser(
          id: id,
          email: email,
          username: username,
        ));
      } else {
        scope.setUser(null);
      }
    });
  }

  /// Clear user data (e.g. on logout).
  Future<void> clearUser() async {
    if (!_initialized) return;

    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }
}
