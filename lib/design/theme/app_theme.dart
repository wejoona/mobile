import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/theme/theme_extensions.dart';

/// App Theme Configuration
/// Luxury themes with gold accents - supports both dark and light modes
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

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

      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsLight.canvas,
        foregroundColor: AppColorsLight.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: AppColorsLight.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColorsLight.textPrimary,
          size: 24,
        ),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsLight.container,
        selectedItemColor: AppColorsLight.gold500,
        unselectedItemColor: AppColorsLight.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColorsLight.container,
        indicatorColor: AppColorsLight.gold500.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColorsLight.gold500, size: 24);
          }
          return const IconThemeData(color: AppColorsLight.textTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColorsLight.gold500,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColorsLight.textTertiary,
          );
        }),
      ),

      cardTheme: CardThemeData(
        color: AppColorsLight.container,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColorsLight.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
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
          textStyle: AppTypography.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsLight.textPrimary,
          side: const BorderSide(color: AppColorsLight.borderDefault),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button.copyWith(color: AppColorsLight.textPrimary),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsLight.gold500,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColorsLight.gold500),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsLight.elevated,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsLight.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsLight.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsLight.gold500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsLight.errorBase),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColorsLight.errorBase, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColorsLight.textSecondary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColorsLight.textTertiary),
        errorStyle: AppTypography.bodySmall.copyWith(color: AppColorsLight.errorText),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColorsLight.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColorsLight.container,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        titleTextStyle: AppTypography.titleLarge.copyWith(color: AppColorsLight.textPrimary),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColorsLight.textSecondary),
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColorsLight.container,
        modalBackgroundColor: AppColorsLight.container,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xxl)),
        ),
        dragHandleColor: AppColorsLight.textTertiary,
        dragHandleSize: Size(40, 4),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsLight.textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: AppColorsLight.textInverse),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTypography.bodyLarge.copyWith(color: AppColorsLight.textPrimary),
        subtitleTextStyle: AppTypography.bodySmall.copyWith(color: AppColorsLight.textSecondary),
        leadingAndTrailingTextStyle: AppTypography.labelMedium.copyWith(color: AppColorsLight.textSecondary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: AppColorsLight.textPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: AppColorsLight.textPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: AppColorsLight.textPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: AppColorsLight.textPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: AppColorsLight.textPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: AppColorsLight.textPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: AppColorsLight.textPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: AppColorsLight.textPrimary),
        titleSmall: AppTypography.titleSmall.copyWith(color: AppColorsLight.textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColorsLight.textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: AppColorsLight.textSecondary),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColorsLight.textSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: AppColorsLight.textPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: AppColorsLight.textSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: AppColorsLight.textSecondary),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // CUSTOM EXTENSIONS
      // ═══════════════════════════════════════════════════════════════════════
      extensions: <ThemeExtension<dynamic>>[
        AppColorsExtension.light,
        AppGradientsExtension.light,
        AppShadowsExtension.shared,
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // ═══════════════════════════════════════════════════════════════════════
      // COLOR SCHEME
      // ═══════════════════════════════════════════════════════════════════════
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

      // ═══════════════════════════════════════════════════════════════════════
      // SCAFFOLD
      // ═══════════════════════════════════════════════════════════════════════
      scaffoldBackgroundColor: AppColors.obsidian,

      // ═══════════════════════════════════════════════════════════════════════
      // APP BAR
      // ═══════════════════════════════════════════════════════════════════════
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.obsidian,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: AppTypography.titleLarge,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // BOTTOM NAVIGATION
      // ═══════════════════════════════════════════════════════════════════════
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.graphite,
        selectedItemColor: AppColors.gold500,
        unselectedItemColor: AppColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // NAVIGATION BAR (Material 3)
      // ═══════════════════════════════════════════════════════════════════════
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.graphite,
        indicatorColor: AppColors.gold500.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.gold500, size: 24);
          }
          return const IconThemeData(color: AppColors.textTertiary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gold500,
            );
          }
          return const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.textTertiary,
          );
        }),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // CARDS
      // ═══════════════════════════════════════════════════════════════════════
      cardTheme: CardThemeData(
        color: AppColors.slate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // ELEVATED BUTTON
      // ═══════════════════════════════════════════════════════════════════════
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
          textStyle: AppTypography.button,
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // OUTLINED BUTTON
      // ═══════════════════════════════════════════════════════════════════════
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.borderDefault),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppTypography.button.copyWith(color: AppColors.textPrimary),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // TEXT BUTTON
      // ═══════════════════════════════════════════════════════════════════════
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.gold500,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTypography.labelLarge.copyWith(color: AppColors.gold500),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // INPUT DECORATION
      // ═══════════════════════════════════════════════════════════════════════
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorBase),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.errorBase, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
        errorStyle: AppTypography.bodySmall.copyWith(color: AppColors.errorText),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // DIVIDER
      // ═══════════════════════════════════════════════════════════════════════
      dividerTheme: const DividerThemeData(
        color: AppColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // DIALOG
      // ═══════════════════════════════════════════════════════════════════════
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.slate,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // BOTTOM SHEET
      // ═══════════════════════════════════════════════════════════════════════
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

      // ═══════════════════════════════════════════════════════════════════════
      // SNACKBAR
      // ═══════════════════════════════════════════════════════════════════════
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.slate,
        contentTextStyle: AppTypography.bodyMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // LIST TILE
      // ═══════════════════════════════════════════════════════════════════════
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        titleTextStyle: AppTypography.bodyLarge,
        subtitleTextStyle: AppTypography.bodySmall,
        leadingAndTrailingTextStyle: AppTypography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // TEXT THEME
      // ═══════════════════════════════════════════════════════════════════════
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),

      // ═══════════════════════════════════════════════════════════════════════
      // CUSTOM EXTENSIONS
      // ═══════════════════════════════════════════════════════════════════════
      extensions: <ThemeExtension<dynamic>>[
        AppColorsExtension.dark,
        AppGradientsExtension.dark,
        AppShadowsExtension.shared,
      ],
    );
  }
}
