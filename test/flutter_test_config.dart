import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

/// Global test configuration for Flutter tests.
/// This file is automatically detected by Flutter's test runner.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Allow Google Fonts to fetch at runtime (needed for tests that use app screens)
  // Tests should use pump() with short duration instead of pumpAndSettle() to avoid
  // waiting for network requests
  GoogleFonts.config.allowRuntimeFetching = true;

  // Override HTTP client with short timeout to fail font requests quickly
  HttpOverrides.global = _TestHttpOverrides();

  await testMain();
}

/// HTTP overrides to handle network requests in tests
/// Uses short connection timeout so font requests fail quickly
class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(milliseconds: 100)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
