import 'dart:async';
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdc_wallet/config/environment_config.dart';
import 'package:usdc_wallet/design/theme/app_theme.dart';
import 'package:usdc_wallet/design/theme/theme_provider.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/mocks/mock_config.dart';
import 'package:usdc_wallet/router/app_router.dart';
import 'package:usdc_wallet/services/analytics/crash_reporting_service.dart';
import 'package:usdc_wallet/services/app_lifecycle/app_lifecycle_observer.dart';
import 'package:usdc_wallet/services/app_version/mobile_version_policy_service.dart';
import 'package:usdc_wallet/services/error_tracking/sentry_service.dart';
import 'package:usdc_wallet/services/feature_flags/feature_flags_provider.dart';
import 'package:usdc_wallet/services/localization/language_provider.dart';
import 'package:usdc_wallet/services/notifications/notification_handler.dart';
import 'package:usdc_wallet/services/security/security_gate.dart';
import 'package:usdc_wallet/services/session/session_manager.dart';
import 'package:usdc_wallet/services/storage/local_cache_service.dart';
import 'package:usdc_wallet/services/storage/sync_service.dart';
import 'package:usdc_wallet/utils/logger.dart';

const _mainLogger = AppLogger('Main');
const _installMarkerKey = 'korido.install.marker.v1';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MockConfig.configureFromEnvironment();

  // Initialize Sentry first so startup failures before runApp are still
  // reported for TestFlight and internal dogfood builds.
  final sentryService = SentryService();
  await sentryService.initializeAndRunApp(
    environment: EnvironmentConfig.environment,
    appRunner: () => _bootstrapAndRunApp(sentryService),
  );
}

Future<void> _bootstrapAndRunApp(SentryService sentryService) async {
  await _initializeFirebase();

  // Initialize Crashlytics for error reporting
  final crashReporting = CrashReportingService();
  await crashReporting.initialize();
  _configureGlobalErrorHandlers(crashReporting, sentryService);

  // Initialize Hive for local persistence (before anything else)
  final localCache = LocalCacheService();
  try {
    await localCache.initialize();
  } on Object catch (error) {
    _mainLogger.warn('Hive initialization failed', error);
  }

  // Initialize SharedPreferences for feature flags cache
  final sharedPreferences = await SharedPreferences.getInstance();
  await _clearSecureStorageAfterFreshInstall(sharedPreferences);

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Custom error widget for release mode
  ErrorWidget.builder = (FlutterErrorDetails details) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.errorBase,
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
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

  // SECURITY: Wrap app with SecurityGate to block compromised devices
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        localCacheServiceProvider.overrideWithValue(localCache),
      ],
      child: const SecurityGate(child: KoridoApp()),
    ),
  );
}

void _configureGlobalErrorHandlers(
  CrashReportingService crashReporting,
  SentryService sentryService,
) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(crashReporting.recordError(details.exception, details.stack));
    unawaited(sentryService.captureFlutterError(details));
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    unawaited(crashReporting.recordError(error, stack, fatal: true));
    unawaited(sentryService.captureException(error, stackTrace: stack));
    return true;
  };
}

Future<void> _clearSecureStorageAfterFreshInstall(
  SharedPreferences sharedPreferences,
) async {
  if (sharedPreferences.getBool(_installMarkerKey) ?? false) {
    return;
  }

  const storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  try {
    await storage.deleteAll();
    _mainLogger.info('Cleared stale secure storage for fresh install');
  } on Object catch (error) {
    _mainLogger.warn('Unable to clear secure storage on fresh install', error);
  }

  await sharedPreferences.setBool(_installMarkerKey, true);
}

Future<void> _initializeFirebase() async {
  if (MockConfig.useMocks) {
    return;
  }

  try {
    await Firebase.initializeApp();
  } on Object catch (error) {
    const logger = AppLogger('Firebase');
    if (EnvironmentConfig.isProduction) {
      logger.error('Firebase initialization failed', error);
      return;
    }

    logger.debug(
      'Firebase unavailable in this build; push and analytics disabled.',
    );
  }
}

class KoridoApp extends ConsumerStatefulWidget {
  const KoridoApp({super.key});

  @override
  ConsumerState<KoridoApp> createState() => _KoridoAppState();
}

class _KoridoAppState extends ConsumerState<KoridoApp> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      // Initialize app lifecycle observer for auto-lock on background.
      ref.read(appLifecycleObserverProvider);

      // Startup side effects must happen after the first build so Riverpod
      // state changes cannot race the initial widget tree construction.
      unawaited(ref.read(localSyncServiceProvider).onAppStart());
      unawaited(ref.read(mobileVersionPolicyProvider.notifier).check());
    });
  }

  @override
  Widget build(BuildContext context) {
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
          supportedLocales: const [Locale('en'), Locale('fr')],
          routerConfig: router,
          builder: (context, child) => NotificationHandler(
            child: SessionManager(child: child ?? const SizedBox.shrink()),
          ),
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
