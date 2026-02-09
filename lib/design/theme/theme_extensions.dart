import 'package:flutter/material.dart';
import '../tokens/index.dart';

// ═══════════════════════════════════════════════════════════════════════════
// CUSTOM THEME EXTENSIONS
// Extend Material 3 ThemeData with app-specific design tokens
// ═══════════════════════════════════════════════════════════════════════════

/// Custom color extension for additional brand colors not in Material 3 ColorScheme
/// Access via Theme.of(context).extension<AppColorsExtension>()!
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Background colors
  final Color backgroundPrimary;
  final Color backgroundSecondary;
  final Color backgroundTertiary;
  final Color backgroundElevated;

  // Text colors
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color textInverse;

  // Border colors
  final Color borderSubtle;
  final Color borderDefault;
  final Color borderStrong;
  final Color borderGold;
  final Color borderGoldStrong;

  // Overlay colors
  final Color overlayLight;
  final Color overlayMedium;
  final Color overlayDark;
  final Color overlayScrim;

  // Semantic colors
  final Color successBase;
  final Color successLight;
  final Color successDark;
  final Color successText;

  final Color warningBase;
  final Color warningLight;
  final Color warningDark;
  final Color warningText;

  final Color errorBase;
  final Color errorLight;
  final Color errorDark;
  final Color errorText;

  final Color infoBase;
  final Color infoLight;
  final Color infoDark;
  final Color infoText;

  // Gold palette
  final Color gold50;
  final Color gold100;
  final Color gold200;
  final Color gold300;
  final Color gold400;
  final Color gold500;
  final Color gold600;
  final Color gold700;
  final Color gold800;
  final Color gold900;

  const AppColorsExtension({
    required this.backgroundPrimary,
    required this.backgroundSecondary,
    required this.backgroundTertiary,
    required this.backgroundElevated,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.textInverse,
    required this.borderSubtle,
    required this.borderDefault,
    required this.borderStrong,
    required this.borderGold,
    required this.borderGoldStrong,
    required this.overlayLight,
    required this.overlayMedium,
    required this.overlayDark,
    required this.overlayScrim,
    required this.successBase,
    required this.successLight,
    required this.successDark,
    required this.successText,
    required this.warningBase,
    required this.warningLight,
    required this.warningDark,
    required this.warningText,
    required this.errorBase,
    required this.errorLight,
    required this.errorDark,
    required this.errorText,
    required this.infoBase,
    required this.infoLight,
    required this.infoDark,
    required this.infoText,
    required this.gold50,
    required this.gold100,
    required this.gold200,
    required this.gold300,
    required this.gold400,
    required this.gold500,
    required this.gold600,
    required this.gold700,
    required this.gold800,
    required this.gold900,
  });

  /// Dark theme colors
  static const dark = AppColorsExtension(
    backgroundPrimary: AppColors.obsidian,
    backgroundSecondary: AppColors.graphite,
    backgroundTertiary: AppColors.slate,
    backgroundElevated: AppColors.elevated,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    textDisabled: AppColors.textDisabled,
    textInverse: AppColors.textInverse,
    borderSubtle: AppColors.borderSubtle,
    borderDefault: AppColors.borderDefault,
    borderStrong: AppColors.borderStrong,
    borderGold: AppColors.borderGold,
    borderGoldStrong: AppColors.borderGoldStrong,
    overlayLight: AppColors.overlayLight,
    overlayMedium: AppColors.overlayMedium,
    overlayDark: AppColors.overlayDark,
    overlayScrim: AppColors.overlayScrim,
    successBase: AppColors.successBase,
    successLight: AppColors.successLight,
    successDark: AppColors.successDark,
    successText: AppColors.successText,
    warningBase: AppColors.warningBase,
    warningLight: AppColors.warningLight,
    warningDark: AppColors.warningDark,
    warningText: AppColors.warningText,
    errorBase: AppColors.errorBase,
    errorLight: AppColors.errorLight,
    errorDark: AppColors.errorDark,
    errorText: AppColors.errorText,
    infoBase: AppColors.infoBase,
    infoLight: AppColors.infoLight,
    infoDark: AppColors.infoDark,
    infoText: AppColors.infoText,
    gold50: AppColors.gold50,
    gold100: AppColors.gold100,
    gold200: AppColors.gold200,
    gold300: AppColors.gold300,
    gold400: AppColors.gold400,
    gold500: AppColors.gold500,
    gold600: AppColors.gold600,
    gold700: AppColors.gold700,
    gold800: AppColors.gold800,
    gold900: AppColors.gold900,
  );

  /// Light theme colors
  static const light = AppColorsExtension(
    backgroundPrimary: AppColorsLight.canvas,
    backgroundSecondary: AppColorsLight.surface,
    backgroundTertiary: AppColorsLight.container,
    backgroundElevated: AppColorsLight.elevated,
    textPrimary: AppColorsLight.textPrimary,
    textSecondary: AppColorsLight.textSecondary,
    textTertiary: AppColorsLight.textTertiary,
    textDisabled: AppColorsLight.textDisabled,
    textInverse: AppColorsLight.textInverse,
    borderSubtle: AppColorsLight.borderSubtle,
    borderDefault: AppColorsLight.borderDefault,
    borderStrong: AppColorsLight.borderStrong,
    borderGold: AppColorsLight.borderGold,
    borderGoldStrong: AppColorsLight.borderGoldStrong,
    overlayLight: AppColorsLight.overlayLight,
    overlayMedium: AppColorsLight.overlayMedium,
    overlayDark: AppColorsLight.overlayDark,
    overlayScrim: AppColorsLight.overlayScrim,
    successBase: AppColorsLight.successBase,
    successLight: AppColorsLight.successLight,
    successDark: AppColors.successDark, // Not defined in light, use dark
    successText: AppColorsLight.successText,
    warningBase: AppColorsLight.warningBase,
    warningLight: AppColorsLight.warningLight,
    warningDark: AppColors.warningDark, // Not defined in light, use dark
    warningText: AppColorsLight.warningText,
    errorBase: AppColorsLight.errorBase,
    errorLight: AppColorsLight.errorLight,
    errorDark: AppColors.errorDark, // Not defined in light, use dark
    errorText: AppColorsLight.errorText,
    infoBase: AppColorsLight.infoBase,
    infoLight: AppColorsLight.infoLight,
    infoDark: AppColors.infoDark, // Not defined in light, use dark
    infoText: AppColorsLight.infoText,
    gold50: AppColors.gold50,
    gold100: AppColors.gold100,
    gold200: AppColors.gold200,
    gold300: AppColors.gold300,
    gold400: AppColors.gold400,
    gold500: AppColorsLight.gold500,
    gold600: AppColorsLight.gold600,
    gold700: AppColorsLight.gold700,
    gold800: AppColors.gold800,
    gold900: AppColors.gold900,
  );

  @override
  ThemeExtension<AppColorsExtension> copyWith({
    Color? backgroundPrimary,
    Color? backgroundSecondary,
    Color? backgroundTertiary,
    Color? backgroundElevated,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textDisabled,
    Color? textInverse,
    Color? borderSubtle,
    Color? borderDefault,
    Color? borderStrong,
    Color? borderGold,
    Color? borderGoldStrong,
    Color? overlayLight,
    Color? overlayMedium,
    Color? overlayDark,
    Color? overlayScrim,
    Color? successBase,
    Color? successLight,
    Color? successDark,
    Color? successText,
    Color? warningBase,
    Color? warningLight,
    Color? warningDark,
    Color? warningText,
    Color? errorBase,
    Color? errorLight,
    Color? errorDark,
    Color? errorText,
    Color? infoBase,
    Color? infoLight,
    Color? infoDark,
    Color? infoText,
    Color? gold50,
    Color? gold100,
    Color? gold200,
    Color? gold300,
    Color? gold400,
    Color? gold500,
    Color? gold600,
    Color? gold700,
    Color? gold800,
    Color? gold900,
  }) {
    return AppColorsExtension(
      backgroundPrimary: backgroundPrimary ?? this.backgroundPrimary,
      backgroundSecondary: backgroundSecondary ?? this.backgroundSecondary,
      backgroundTertiary: backgroundTertiary ?? this.backgroundTertiary,
      backgroundElevated: backgroundElevated ?? this.backgroundElevated,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textInverse: textInverse ?? this.textInverse,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      borderGold: borderGold ?? this.borderGold,
      borderGoldStrong: borderGoldStrong ?? this.borderGoldStrong,
      overlayLight: overlayLight ?? this.overlayLight,
      overlayMedium: overlayMedium ?? this.overlayMedium,
      overlayDark: overlayDark ?? this.overlayDark,
      overlayScrim: overlayScrim ?? this.overlayScrim,
      successBase: successBase ?? this.successBase,
      successLight: successLight ?? this.successLight,
      successDark: successDark ?? this.successDark,
      successText: successText ?? this.successText,
      warningBase: warningBase ?? this.warningBase,
      warningLight: warningLight ?? this.warningLight,
      warningDark: warningDark ?? this.warningDark,
      warningText: warningText ?? this.warningText,
      errorBase: errorBase ?? this.errorBase,
      errorLight: errorLight ?? this.errorLight,
      errorDark: errorDark ?? this.errorDark,
      errorText: errorText ?? this.errorText,
      infoBase: infoBase ?? this.infoBase,
      infoLight: infoLight ?? this.infoLight,
      infoDark: infoDark ?? this.infoDark,
      infoText: infoText ?? this.infoText,
      gold50: gold50 ?? this.gold50,
      gold100: gold100 ?? this.gold100,
      gold200: gold200 ?? this.gold200,
      gold300: gold300 ?? this.gold300,
      gold400: gold400 ?? this.gold400,
      gold500: gold500 ?? this.gold500,
      gold600: gold600 ?? this.gold600,
      gold700: gold700 ?? this.gold700,
      gold800: gold800 ?? this.gold800,
      gold900: gold900 ?? this.gold900,
    );
  }

  @override
  ThemeExtension<AppColorsExtension> lerp(
    ThemeExtension<AppColorsExtension>? other,
    double t,
  ) {
    if (other is! AppColorsExtension) return this;

    return AppColorsExtension(
      backgroundPrimary: Color.lerp(backgroundPrimary, other.backgroundPrimary, t)!,
      backgroundSecondary: Color.lerp(backgroundSecondary, other.backgroundSecondary, t)!,
      backgroundTertiary: Color.lerp(backgroundTertiary, other.backgroundTertiary, t)!,
      backgroundElevated: Color.lerp(backgroundElevated, other.backgroundElevated, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      borderGold: Color.lerp(borderGold, other.borderGold, t)!,
      borderGoldStrong: Color.lerp(borderGoldStrong, other.borderGoldStrong, t)!,
      overlayLight: Color.lerp(overlayLight, other.overlayLight, t)!,
      overlayMedium: Color.lerp(overlayMedium, other.overlayMedium, t)!,
      overlayDark: Color.lerp(overlayDark, other.overlayDark, t)!,
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
      successBase: Color.lerp(successBase, other.successBase, t)!,
      successLight: Color.lerp(successLight, other.successLight, t)!,
      successDark: Color.lerp(successDark, other.successDark, t)!,
      successText: Color.lerp(successText, other.successText, t)!,
      warningBase: Color.lerp(warningBase, other.warningBase, t)!,
      warningLight: Color.lerp(warningLight, other.warningLight, t)!,
      warningDark: Color.lerp(warningDark, other.warningDark, t)!,
      warningText: Color.lerp(warningText, other.warningText, t)!,
      errorBase: Color.lerp(errorBase, other.errorBase, t)!,
      errorLight: Color.lerp(errorLight, other.errorLight, t)!,
      errorDark: Color.lerp(errorDark, other.errorDark, t)!,
      errorText: Color.lerp(errorText, other.errorText, t)!,
      infoBase: Color.lerp(infoBase, other.infoBase, t)!,
      infoLight: Color.lerp(infoLight, other.infoLight, t)!,
      infoDark: Color.lerp(infoDark, other.infoDark, t)!,
      infoText: Color.lerp(infoText, other.infoText, t)!,
      gold50: Color.lerp(gold50, other.gold50, t)!,
      gold100: Color.lerp(gold100, other.gold100, t)!,
      gold200: Color.lerp(gold200, other.gold200, t)!,
      gold300: Color.lerp(gold300, other.gold300, t)!,
      gold400: Color.lerp(gold400, other.gold400, t)!,
      gold500: Color.lerp(gold500, other.gold500, t)!,
      gold600: Color.lerp(gold600, other.gold600, t)!,
      gold700: Color.lerp(gold700, other.gold700, t)!,
      gold800: Color.lerp(gold800, other.gold800, t)!,
      gold900: Color.lerp(gold900, other.gold900, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GRADIENTS EXTENSION
// ═══════════════════════════════════════════════════════════════════════════

/// Gradient extension for common brand gradients
/// Access via Theme.of(context).extension<AppGradientsExtension>()!
class AppGradientsExtension extends ThemeExtension<AppGradientsExtension> {
  final LinearGradient goldGradient;
  final LinearGradient goldGradientVertical;
  final LinearGradient shimmerGradient;
  final LinearGradient glassGradient;
  final RadialGradient goldRadialGradient;
  final SweepGradient goldSweepGradient;

  const AppGradientsExtension({
    required this.goldGradient,
    required this.goldGradientVertical,
    required this.shimmerGradient,
    required this.glassGradient,
    required this.goldRadialGradient,
    required this.goldSweepGradient,
  });

  /// Dark theme gradients
  static const dark = AppGradientsExtension(
    goldGradient: LinearGradient(
      colors: [
        AppColors.gold600,
        AppColors.gold500,
        AppColors.gold400,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    goldGradientVertical: LinearGradient(
      colors: [
        AppColors.gold600,
        AppColors.gold500,
        AppColors.gold400,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    shimmerGradient: LinearGradient(
      colors: [
        Color(0x00FFFFFF),
        Color(0x1AFFFFFF),
        Color(0x00FFFFFF),
      ],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
    ),
    glassGradient: LinearGradient(
      colors: [
        Color(0x1AFFFFFF),
        Color(0x0DFFFFFF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    goldRadialGradient: RadialGradient(
      colors: [
        AppColors.gold300,
        AppColors.gold500,
        AppColors.gold700,
      ],
      stops: [0.0, 0.5, 1.0],
    ),
    goldSweepGradient: SweepGradient(
      colors: [
        AppColors.gold600,
        AppColors.gold400,
        AppColors.gold300,
        AppColors.gold400,
        AppColors.gold600,
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ),
  );

  /// Light theme gradients
  static const light = AppGradientsExtension(
    goldGradient: LinearGradient(
      colors: [
        AppColorsLight.gold600,
        AppColorsLight.gold500,
        AppColors.gold400,
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    goldGradientVertical: LinearGradient(
      colors: [
        AppColorsLight.gold600,
        AppColorsLight.gold500,
        AppColors.gold400,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
    shimmerGradient: LinearGradient(
      colors: [
        Color(0x00000000),
        Color(0x1A000000),
        Color(0x00000000),
      ],
      stops: [0.0, 0.5, 1.0],
      begin: Alignment(-1.0, -0.3),
      end: Alignment(1.0, 0.3),
    ),
    glassGradient: LinearGradient(
      colors: [
        Color(0x1AFFFFFF),
        Color(0x0DFFFFFF),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    goldRadialGradient: RadialGradient(
      colors: [
        AppColors.gold300,
        AppColorsLight.gold500,
        AppColorsLight.gold700,
      ],
      stops: [0.0, 0.5, 1.0],
    ),
    goldSweepGradient: SweepGradient(
      colors: [
        AppColorsLight.gold600,
        AppColors.gold400,
        AppColors.gold300,
        AppColors.gold400,
        AppColorsLight.gold600,
      ],
      stops: [0.0, 0.25, 0.5, 0.75, 1.0],
    ),
  );

  @override
  ThemeExtension<AppGradientsExtension> copyWith({
    LinearGradient? goldGradient,
    LinearGradient? goldGradientVertical,
    LinearGradient? shimmerGradient,
    LinearGradient? glassGradient,
    RadialGradient? goldRadialGradient,
    SweepGradient? goldSweepGradient,
  }) {
    return AppGradientsExtension(
      goldGradient: goldGradient ?? this.goldGradient,
      goldGradientVertical: goldGradientVertical ?? this.goldGradientVertical,
      shimmerGradient: shimmerGradient ?? this.shimmerGradient,
      glassGradient: glassGradient ?? this.glassGradient,
      goldRadialGradient: goldRadialGradient ?? this.goldRadialGradient,
      goldSweepGradient: goldSweepGradient ?? this.goldSweepGradient,
    );
  }

  @override
  ThemeExtension<AppGradientsExtension> lerp(
    ThemeExtension<AppGradientsExtension>? other,
    double t,
  ) {
    if (other is! AppGradientsExtension) return this;

    return AppGradientsExtension(
      goldGradient: LinearGradient.lerp(goldGradient, other.goldGradient, t)!,
      goldGradientVertical: LinearGradient.lerp(goldGradientVertical, other.goldGradientVertical, t)!,
      shimmerGradient: LinearGradient.lerp(shimmerGradient, other.shimmerGradient, t)!,
      glassGradient: LinearGradient.lerp(glassGradient, other.glassGradient, t)!,
      goldRadialGradient: RadialGradient.lerp(goldRadialGradient, other.goldRadialGradient, t)!,
      goldSweepGradient: SweepGradient.lerp(goldSweepGradient, other.goldSweepGradient, t)!,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHADOWS EXTENSION
// ═══════════════════════════════════════════════════════════════════════════

/// Shadow extension for elevation and glow effects
/// Access via Theme.of(context).extension<AppShadowsExtension>()!
class AppShadowsExtension extends ThemeExtension<AppShadowsExtension> {
  final List<BoxShadow> none;
  final List<BoxShadow> sm;
  final List<BoxShadow> md;
  final List<BoxShadow> lg;
  final List<BoxShadow> xl;
  final List<BoxShadow> card;
  final List<BoxShadow> cardHover;
  final List<BoxShadow> goldGlow;
  final List<BoxShadow> goldGlowStrong;
  final List<BoxShadow> successGlow;
  final List<BoxShadow> errorGlow;

  const AppShadowsExtension({
    required this.none,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.card,
    required this.cardHover,
    required this.goldGlow,
    required this.goldGlowStrong,
    required this.successGlow,
    required this.errorGlow,
  });

  /// Dark and light themes use the same shadows
  static final shared = AppShadowsExtension(
    none: AppShadows.none,
    sm: AppShadows.sm,
    md: AppShadows.md,
    lg: AppShadows.lg,
    xl: AppShadows.xl,
    card: AppShadows.card,
    cardHover: AppShadows.cardHover,
    goldGlow: AppShadows.goldGlow,
    goldGlowStrong: AppShadows.goldGlowStrong,
    successGlow: AppShadows.successGlow,
    errorGlow: AppShadows.errorGlow,
  );

  @override
  ThemeExtension<AppShadowsExtension> copyWith({
    List<BoxShadow>? none,
    List<BoxShadow>? sm,
    List<BoxShadow>? md,
    List<BoxShadow>? lg,
    List<BoxShadow>? xl,
    List<BoxShadow>? card,
    List<BoxShadow>? cardHover,
    List<BoxShadow>? goldGlow,
    List<BoxShadow>? goldGlowStrong,
    List<BoxShadow>? successGlow,
    List<BoxShadow>? errorGlow,
  }) {
    return AppShadowsExtension(
      none: none ?? this.none,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      card: card ?? this.card,
      cardHover: cardHover ?? this.cardHover,
      goldGlow: goldGlow ?? this.goldGlow,
      goldGlowStrong: goldGlowStrong ?? this.goldGlowStrong,
      successGlow: successGlow ?? this.successGlow,
      errorGlow: errorGlow ?? this.errorGlow,
    );
  }

  @override
  ThemeExtension<AppShadowsExtension> lerp(
    ThemeExtension<AppShadowsExtension>? other,
    double t,
  ) {
    if (other is! AppShadowsExtension) return this;

    return AppShadowsExtension(
      none: BoxShadow.lerpList(none, other.none, t) ?? none,
      sm: BoxShadow.lerpList(sm, other.sm, t) ?? sm,
      md: BoxShadow.lerpList(md, other.md, t) ?? md,
      lg: BoxShadow.lerpList(lg, other.lg, t) ?? lg,
      xl: BoxShadow.lerpList(xl, other.xl, t) ?? xl,
      card: BoxShadow.lerpList(card, other.card, t) ?? card,
      cardHover: BoxShadow.lerpList(cardHover, other.cardHover, t) ?? cardHover,
      goldGlow: BoxShadow.lerpList(goldGlow, other.goldGlow, t) ?? goldGlow,
      goldGlowStrong: BoxShadow.lerpList(goldGlowStrong, other.goldGlowStrong, t) ?? goldGlowStrong,
      successGlow: BoxShadow.lerpList(successGlow, other.successGlow, t) ?? successGlow,
      errorGlow: BoxShadow.lerpList(errorGlow, other.errorGlow, t) ?? errorGlow,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CONVENIENCE EXTENSIONS ON BuildContext
// ═══════════════════════════════════════════════════════════════════════════

extension ThemeExtensionsContext on BuildContext {
  /// Quick access to custom colors
  /// Usage: context.appColors.gold500
  AppColorsExtension get appColors {
    return Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.dark;
  }

  /// Quick access to gradients
  /// Usage: context.appGradients.goldGradient
  AppGradientsExtension get appGradients {
    return Theme.of(this).extension<AppGradientsExtension>() ?? AppGradientsExtension.dark;
  }

  /// Quick access to shadows
  /// Usage: context.appShadows.goldGlow
  AppShadowsExtension get appShadows {
    return Theme.of(this).extension<AppShadowsExtension>() ?? AppShadowsExtension.shared;
  }

  /// Check if current theme is dark
  /// Usage: context.isDarkMode
  bool get isDarkMode {
    return Theme.of(this).brightness == Brightness.dark;
  }
}
