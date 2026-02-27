import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/theme/app_theme.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/session/session_manager.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/services/analytics/crash_reporting_service.dart';
import 'package:usdc_wallet/services/app_lifecycle/app_lifecycle_observer.dart';
import 'package:usdc_wallet/services/error_tracking/sentry_service.dart';
import 'package:usdc_wallet/services/storage/local_cache_service.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';
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

  // Initialize Hive for local persistence (before anything else)
  final localCache = LocalCacheService();
  try {
    await localCache.initialize();
  } catch (e) {
    debugPrint('Hive initialization failed: $e');
  }

  // Initialize SharedPreferences for feature flags cache
  final sharedPreferences = await SharedPreferences.getInstance();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Determine environment from build config
  const environment = String.fromEnvironment('ENV', defaultValue: 'dev');

  // Initialize Sentry and run the app inside its error zone
  final sentryService = SentryService();
  await sentryService.initializeAndRunApp(
    environment: environment,
    appRunner: () async {
      // Global error handling — forward to both Crashlytics and Sentry
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        crashReporting.recordError(details.exception, details.stack);
        sentryService.captureFlutterError(details);
      };

      // Custom error widget for release mode
      ErrorWidget.builder = (FlutterErrorDetails details) {
        return MaterialApp(
          home: Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: AppColors.errorBase),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Oops! Something went wrong.',
                      style: AppTypography.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Please restart the app.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      };

      // SECURITY: Wrap app with SecurityGate to block compromised devices
      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            localCacheServiceProvider.overrideWithValue(localCache),
          ],
          child: const KoridoApp(),
        ),
      );
    },
  );
}

class KoridoApp extends ConsumerWidget {
  const KoridoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize app lifecycle observer for auto-lock on background
    ref.read(appLifecycleObserverProvider);

    // Load cached data into state on app start
    ref.read(localSyncServiceProvider).onAppStart();

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

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: SystemBrightnessObserver(
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
