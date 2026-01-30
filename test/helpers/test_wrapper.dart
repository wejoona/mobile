import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Test wrapper that provides theme, localization, and Riverpod
class TestWrapper extends StatelessWidget {
  const TestWrapper({
    super.key,
    required this.child,
    this.overrides = const [],
    this.locale = const Locale('en'),
  });

  final Widget child;
  final List<Override> overrides;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData.dark().copyWith(
          extensions: const [AppThemeColors.dark],
        ),
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
    this.overrides = const [],
    this.navigatorObserver,
  });

  final Widget child;
  final List<Override> overrides;
  final NavigatorObserver? navigatorObserver;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        navigatorObservers: navigatorObserver != null ? [navigatorObserver!] : [],
        theme: ThemeData.dark().copyWith(
          extensions: const [AppThemeColors.dark],
        ),
        home: child,
      ),
    );
  }
}
