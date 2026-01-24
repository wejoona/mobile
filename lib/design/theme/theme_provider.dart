import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_theme.dart';
import '../tokens/colors.dart';

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
        systemNavigationBarColor: AppColors.graphite,
        systemNavigationBarIconBrightness: Brightness.light,
      );
    } else {
      return const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: AppColorsLight.container,
        systemNavigationBarIconBrightness: Brightness.dark,
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

/// Theme notifier for managing theme state
class ThemeNotifier extends StateNotifier<ThemeState> {
  static const _storageKey = 'app_theme_mode';
  final FlutterSecureStorage _storage;

  ThemeNotifier(this._storage) : super(const ThemeState()) {
    _loadSavedTheme();
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

  /// Set theme mode and persist
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(mode: mode);
    try {
      await _storage.write(key: _storageKey, value: mode.name);
    } catch (e) {
      // Ignore storage errors
    }
  }

  /// Toggle between light and dark (ignoring system)
  Future<void> toggleTheme() async {
    final newMode = state.mode == AppThemeMode.dark
        ? AppThemeMode.light
        : AppThemeMode.dark;
    await setThemeMode(newMode);
  }
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return ThemeNotifier(storage);
});
