import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global test configuration for Flutter tests.
/// This file is automatically detected by Flutter's test runner.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final runE2E =
      Platform.environment['RUN_E2E'] == 'true' ||
      const bool.fromEnvironment('RUN_E2E');

  // Allow Google Fonts to fetch at runtime (needed for tests that use app screens)
  // Tests should use pump() with short duration instead of pumpAndSettle() to avoid
  // waiting for network requests
  GoogleFonts.config.allowRuntimeFetching = false;

  // Override HTTP client with short timeout to fail font requests quickly
  HttpOverrides.global = _TestHttpOverrides(
    connectionTimeout: runE2E
        ? const Duration(seconds: 10)
        : const Duration(milliseconds: 100),
  );

  await testMain();
}

/// HTTP overrides to handle network requests in tests
/// Uses short connection timeout so font requests fail quickly
class _TestHttpOverrides extends HttpOverrides {
  _TestHttpOverrides({required this.connectionTimeout});

  final Duration connectionTimeout;

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = connectionTimeout
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
