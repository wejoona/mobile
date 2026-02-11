import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_theme.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'theme_transition.dart';

/// Theme mode state - supports system, light, and dark
enum AppThemeMode {
  system,
  light,
  dark,
}

/// Theme state that holds the current mode
class ThemeState {
  final AppThemeMode mode;

  const ThemeState({this.mode = AppThemeMode.system});

  ThemeState copyWith({AppThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  /// Get the appropriate ThemeData based on mode and system brightness
  ThemeData getTheme(Brightness systemBrightness) {
    switch (mode) {
      case AppThemeMode.light:
        return AppTheme.lightTheme;
      case AppThemeMode.dark:
        return AppTheme.darkTheme;
      case AppThemeMode.system:
        return systemBrightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    }
  }

  /// Get the appropriate system UI overlay style
  SystemUiOverlayStyle getSystemUiStyle(Brightness systemBrightness) {
    final isDark = mode == AppThemeMode.dark ||
        (mode == AppThemeMode.system && systemBrightness == Brightness.dark);

    if (isDark) {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColors.graphite,
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarDividerColor: Colors.transparent,
      );
    } else {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColorsLight.container,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Colors.transparent,
      );
    }
  }

  /// Check if current theme is dark (accounting for system mode)
  bool isDark(Brightness systemBrightness) {
    switch (mode) {
      case AppThemeMode.light:
        return false;
      case AppThemeMode.dark:
        return true;
      case AppThemeMode.system:
        return systemBrightness == Brightness.dark;
    }
  }
}

/// Theme notifier for managing theme state (Riverpod 3.x API)
class ThemeNotifier extends Notifier<ThemeState> {
  static const _storageKey = 'app_theme_mode';

  FlutterSecureStorage get _storage => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  ThemeState build() {
    _loadSavedTheme();
    return const ThemeState();
  }

  /// Load theme preference from storage
  Future<void> _loadSavedTheme() async {
    try {
      final savedMode = await _storage.read(key: _storageKey);
      if (savedMode != null) {
        final mode = AppThemeMode.values.firstWhere(
          (m) => m.name == savedMode,
          orElse: () => AppThemeMode.system,
        );
        state = ThemeState(mode: mode);
      }
    } catch (e) {
      // Ignore errors, use default
    }
  }

  /// Set theme mode and persist with smooth status bar transition
  Future<void> setThemeMode(
    AppThemeMode mode, {
    Brightness? systemBrightness,
    bool animated = true,
  }) async {
    final previousState = state;
    state = state.copyWith(mode: mode);

    try {
      await _storage.write(key: _storageKey, value: mode.name);
    } catch (e) {
      // Ignore storage errors
    }

    // Smooth status bar transition
    if (systemBrightness != null) {
      final wasDark = previousState.isDark(systemBrightness);
      final isDark = state.isDark(systemBrightness);

      if (wasDark != isDark) {
        if (animated) {
          // Animated transition with color interpolation
          final previousStyle = previousState.getSystemUiStyle(systemBrightness);
          final newStyle = state.getSystemUiStyle(systemBrightness);
          await StatusBarTransition.animate(
            from: previousStyle,
            to: newStyle,
            duration: const Duration(milliseconds: 300),
          );
        } else {
          // Immediate transition
          StatusBarTransition.setImmediate(
            state.getSystemUiStyle(systemBrightness),
          );
        }
      }
    }
  }

  /// Toggle between light and dark (ignoring system)
  /// Optionally provide system brightness for smooth status bar transition
  Future<void> toggleTheme({
    Brightness? systemBrightness,
    bool animated = true,
  }) async {
    final newMode = state.mode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(
      newMode,
      systemBrightness: systemBrightness,
      animated: animated,
    );
  }

  /// Toggle with circular reveal animation from a specific point
  /// Typically used when tapping a theme toggle button
  Future<void> toggleThemeWithReveal({
    required BuildContext context,
    Offset? revealCenter,
  }) async {
    final systemBrightness = MediaQuery.platformBrightnessOf(context);
    final newMode = state.mode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;

    await setThemeMode(
      newMode,
      systemBrightness: systemBrightness,
      animated: true,
    );

    // Note: Circular reveal is handled by AnimatedThemeSwitcher widget
    // This is just for API consistency
  }

  /// Reset to system theme mode
  Future<void> resetToSystem({
    Brightness? systemBrightness,
    bool animated = true,
  }) async {
    await setThemeMode(
      AppThemeMode.system,
      systemBrightness: systemBrightness,
      animated: animated,
    );
  }

  /// Initialize status bar style on app start
  void initializeStatusBar(Brightness systemBrightness) {
    final style = state.getSystemUiStyle(systemBrightness);
    StatusBarTransition.setImmediate(style);
  }
}

/// Theme provider
final themeProvider = NotifierProvider<ThemeNotifier, ThemeState>(
  ThemeNotifier.new,
);

/// System brightness observer that tracks platform brightness changes
/// This ensures real-time theme updates when system mode is active
///
/// Usage:
/// ```dart
/// SystemBrightnessObserver(
///   child: MaterialApp(...),
/// )
/// ```
class SystemBrightnessObserver extends ConsumerStatefulWidget {
  final Widget child;

  const SystemBrightnessObserver({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<SystemBrightnessObserver> createState() => _SystemBrightnessObserverState();
}

class _SystemBrightnessObserverState extends ConsumerState<SystemBrightnessObserver>
    with WidgetsBindingObserver {
  Brightness? _lastBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _lastBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    final currentBrightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;

    // Only update if brightness actually changed
    if (_lastBrightness != currentBrightness) {
      final previousBrightness = _lastBrightness;
      _lastBrightness = currentBrightness;

      // Update system UI overlay to match new brightness with smooth transition
      final themeState = ref.read(themeProvider);

      // Only animate if theme is in system mode
      if (themeState.mode == AppThemeMode.system && previousBrightness != null) {
        final previousStyle = themeState.getSystemUiStyle(previousBrightness);
        final newStyle = themeState.getSystemUiStyle(currentBrightness);

        // Animate status bar transition smoothly
        StatusBarTransition.animate(
          from: previousStyle,
          to: newStyle,
          duration: const Duration(milliseconds: 400),
        );
      } else {
        SystemChrome.setSystemUIOverlayStyle(
          themeState.getSystemUiStyle(currentBrightness),
        );
      }

      // Trigger rebuild to update UI
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
