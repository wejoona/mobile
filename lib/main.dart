import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'design/theme/app_theme.dart';
import 'design/theme/theme_provider.dart';
import 'router/app_router.dart';
import 'services/session/session_manager.dart';
import 'services/security/security_gate.dart';
import 'services/security/device_security.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (gracefully handle missing/invalid config for development)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
    debugPrint('Push notifications will be disabled. Configure Firebase for production.');
  }

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // SECURITY: Wrap app with SecurityGate to block compromised devices
  runApp(
    const SecurityGate(
      policy: CompromisedDevicePolicy.block,
      child: ProviderScope(child: JoonaPayApp()),
    ),
  );
}

class JoonaPayApp extends ConsumerWidget {
  const JoonaPayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeState = ref.watch(themeProvider);
    final systemBrightness = MediaQuery.platformBrightnessOf(context);

    // Update system UI overlay based on theme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setSystemUIOverlayStyle(
        themeState.getSystemUiStyle(systemBrightness),
      );
    });

    return MaterialApp.router(
      title: 'JoonaPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _getThemeMode(themeState.mode),
      routerConfig: router,
      builder: (context, child) {
        // Wrap with SessionManager to handle session lifecycle
        return SessionManager(child: child ?? const SizedBox.shrink());
      },
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
