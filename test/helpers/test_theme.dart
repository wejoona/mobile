import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Test-specific theme that uses system fonts instead of Google Fonts
/// This avoids network fetching issues in tests while maintaining visual styling
class TestTheme {
  TestTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: '.SF Pro Text', // System font for iOS tests

      colorScheme: const ColorScheme.dark(
        primary: AppColors.gold500,
        onPrimary: AppColors.textInverse,
        primaryContainer: AppColors.gold700,
        onPrimaryContainer: AppColors.gold100,
        secondary: AppColors.slate,
        onSecondary: AppColors.textPrimary,
        secondaryContainer: AppColors.elevated,
        onSecondaryContainer: AppColors.textPrimary,
        tertiary: AppColors.successBase,
        onTertiary: AppColors.textPrimary,
        error: AppColors.errorBase,
        onError: AppColors.textPrimary,
        surface: AppColors.graphite,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.slate,
        outline: AppColors.borderDefault,
        outlineVariant: AppColors.borderSubtle,
      ),

      scaffoldBackgroundColor: AppColors.obsidian,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.obsidian,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.gold500,
          foregroundColor: AppColors.textInverse,
          disabledBackgroundColor: AppColors.elevated,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold500,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.gold500, width: 2),
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.slate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.slate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.slate,
        modalBackgroundColor: AppColors.slate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        dragHandleColor: AppColors.textTertiary,
        dragHandleSize: Size(40, 4),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: '.SF Pro Text',

      colorScheme: const ColorScheme.light(
        primary: AppColorsLight.gold500,
        onPrimary: AppColorsLight.textInverse,
        primaryContainer: AppColors.gold200,
        onPrimaryContainer: AppColors.gold900,
        secondary: AppColorsLight.container,
        onSecondary: AppColorsLight.textPrimary,
        secondaryContainer: AppColorsLight.elevated,
        onSecondaryContainer: AppColorsLight.textPrimary,
        tertiary: AppColorsLight.successBase,
        onTertiary: AppColorsLight.textInverse,
        error: AppColorsLight.errorBase,
        onError: AppColorsLight.textInverse,
        surface: AppColorsLight.surface,
        onSurface: AppColorsLight.textPrimary,
        surfaceContainerHighest: AppColorsLight.container,
        outline: AppColorsLight.borderDefault,
        outlineVariant: AppColorsLight.borderSubtle,
      ),

      scaffoldBackgroundColor: AppColorsLight.canvas,

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorsLight.canvas,
        foregroundColor: AppColorsLight.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: AppColorsLight.textPrimary,
          size: 24,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsLight.gold500,
          foregroundColor: AppColorsLight.textInverse,
          disabledBackgroundColor: AppColorsLight.elevated,
          disabledForegroundColor: AppColorsLight.textDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
    );
  }
}
