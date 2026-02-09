import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'test_theme.dart';

/// Test wrapper that provides theme, localization, and Riverpod
/// Uses TestTheme to avoid Google Fonts network issues in tests
class TestWrapper extends StatelessWidget {
  const TestWrapper({
    super.key,
    required this.child,
    this.locale = const Locale('en'),
    this.useDarkTheme = true,
    this.overrides = const [],
  });

  final Widget child;
  final Locale locale;
  final bool useDarkTheme;
  final List<dynamic> overrides;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: useDarkTheme ? TestTheme.darkTheme : TestTheme.lightTheme,
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }
}

/// Test wrapper for navigation testing
class TestNavigationWrapper extends StatelessWidget {
  const TestNavigationWrapper({
    super.key,
    required this.child,
    this.navigatorObserver,
    this.useDarkTheme = true,
  });

  final Widget child;
  final NavigatorObserver? navigatorObserver;
  final bool useDarkTheme;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: navigatorObserver != null ? [navigatorObserver!] : [],
        theme: useDarkTheme ? TestTheme.darkTheme : TestTheme.lightTheme,
        home: child,
      ),
    );
  }
}
