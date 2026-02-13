import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/theme/app_theme.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/session/session_manager.dart';
import 'package:usdc_wallet/services/security/security_gate.dart';
import 'package:usdc_wallet/services/security/device_security.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/services/analytics/crash_reporting_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (gracefully handle missing/invalid config for development)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    AppLogger('Firebase initialization failed').error('Firebase initialization failed', e);
    AppLogger('Debug').debug('Push notifications and analytics will be disabled. Configure Firebase for production.');
  }

  // Initialize Crashlytics for error reporting
  final crashReporting = CrashReportingService();
  await crashReporting.initialize();

  // Initialize SharedPreferences for feature flags cache
  final sharedPreferences = await SharedPreferences.getInstance();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // SECURITY: Wrap app with SecurityGate to block compromised devices
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const JoonaPayApp(),
    ),
  );
}

class JoonaPayApp extends ConsumerWidget {
  const JoonaPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);
    final localeState = ref.watch(localeProvider);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    // Update system UI overlay based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        themeState.getSystemUiStyle(systemBrightness),
      );
    });

    return SystemBrightnessObserver(
      child: MaterialApp.router(
        title: 'Korido',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: _getThemeMode(themeState.mode),
        themeAnimationDuration: const Duration(milliseconds: 400),
        themeAnimationCurve: Curves.easeInOut,
        locale: localeState.locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'),
          Locale('fr'),
        ],
        routerConfig: router,
        builder: (context, child) {
          // Wrap with SessionManager to handle session lifecycle
          return SessionManager(child: child ?? const SizedBox.shrink());
        },
      ),
    );
  }

  ThemeMode _getThemeMode(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
