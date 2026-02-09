import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/core/haptics/haptic_service.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/index.dart';

import 'test_theme.dart';

/// Creates a fully-wrapped test app with ProviderScope, localization,
/// and theme — everything a widget test needs.
///
/// Usage:
/// ```dart
/// await tester.pumpWidget(createTestApp(MyWidget()));
/// await tester.pumpAndSettle();
/// ```
Widget createTestApp(
  Widget child, {
  bool isDarkMode = true,
  Locale locale = const Locale('en'),
}) =>
    ProviderScope(
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: isDarkMode ? TestTheme.darkTheme : TestTheme.lightTheme,
        home: child,
      ),
    );

/// Creates a test app wrapped in a Scaffold.
Widget createTestAppWithScaffold(
  Widget child, {
  bool isDarkMode = true,
}) =>
    createTestApp(
      Scaffold(body: child),
      isDarkMode: isDarkMode,
    );

/// Initialize test environment — call in setUpAll() for any test file.
Future<void> initTestEnvironment() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;
  MockConfig.enableAllMocks();
  MockConfig.networkDelayMs = 0;
  MockRegistry.initialize();
  HapticService().setEnabled(false);
  SharedPreferences.setMockInitialValues({});
}
