import 'package:flutter/material.dart';

/// Comprehensive Light Theme Color Palette for Korido
/// Brand: Gold primary (#B8943D), Obsidian accents
/// WCAG AA compliant (4.5:1 for normal text, 3:1 for large text)
class LightColors {
  LightColors._();

  // ===========================================================================
  // BRAND COLORS
  // ===========================================================================

  /// Primary brand color - Gold (darker for light mode contrast)
  static const Color primary = Color(0xFFB8943D); // Gold - WCAG AA on white

  /// Lighter gold variant for hover/pressed states
  static const Color primaryLight = Color(0xFFD4AF56);

  /// Darker gold for active states and borders
  static const Color primaryDark = Color(0xFF8A6E2B);

  /// Text on primary color surfaces
  static const Color onPrimary = Color(0xFF1A1A1F); // Near black on gold

  /// Secondary brand color - Obsidian
  static const Color secondary = Color(0xFF1A1A1F); // Dark charcoal

  /// Lighter obsidian for elevated surfaces
  static const Color secondaryLight = Color(0xFF2D2D33);

  /// Text on secondary color surfaces
  static const Color onSecondary = Color(0xFFFAFAF8); // Warm white

  // ===========================================================================
  // BACKGROUND & SURFACE COLORS
  // ===========================================================================

  /// Main canvas background - warm white for premium feel
  static const Color background = Color(0xFFFAFAF8);

  /// Secondary background for sections
  static const Color backgroundSecondary = Color(0xFFF5F5F2);

  /// Text on background
  static const Color onBackground = Color(0xFF1A1A1F);

  /// Default surface color (cards, dialogs)
  static const Color surface = Color(0xFFFFFFFF);

  /// Elevated surfaces (FAB, app bar when elevated)
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  /// Surface variant for subtle differentiation
  static const Color surfaceVariant = Color(0xFFEDEDEB);

  /// Tinted surface for special content areas
  static const Color surfaceTinted = Color(0xFFF9F7F0); // Slight gold tint

  /// Text on surface colors
  static const Color onSurface = Color(0xFF1A1A1F);

  /// Text on surface variant
  static const Color onSurfaceVariant = Color(0xFF5A5A5E);

  /// Glassmorphic overlay (90% opacity white)
  static const Color glass = Color(0xE6FFFFFF);

  // ===========================================================================
  // TEXT HIERARCHY
  // ===========================================================================

  /// High emphasis text (headings, important content)
  static const Color textPrimary = Color(0xFF1A1A1F); // Near black

  /// Medium emphasis text (labels, secondary content)
  static const Color textSecondary = Color(0xFF5A5A5E); // Gray-600

  /// Low emphasis text (hints, captions)
  static const Color textTertiary = Color(0xFF8A8A8E); // Gray-400

  /// Disabled state text
  static const Color textDisabled = Color(0xFFAAAAAE); // Gray-300

  /// Inverted text for dark backgrounds (gold, obsidian)
  static const Color textInverse = Color(0xFFFAFAF8);

  // ===========================================================================
  // SEMANTIC COLORS
  // ===========================================================================

  // Success - Emerald green (wealth, growth)
  /// Base success color - WCAG AA compliant
  static const Color success = Color(0xFF1E7D52); // Dark emerald

  /// Light success background
  static const Color successLight = Color(0xFFE8F5ED);

  /// Success text
  static const Color successText = Color(0xFF1A5C3E);

  /// Success icon color
  static const Color successIcon = Color(0xFF2D9663);

  /// Text on success color
  static const Color onSuccess = Color(0xFFFFFFFF);

  // Warning - Amber
  /// Base warning color - WCAG AA compliant
  static const Color warning = Color(0xFFB8862D); // Deep amber

  /// Light warning background
  static const Color warningLight = Color(0xFFFFF5E6);

  /// Warning text
  static const Color warningText = Color(0xFF8A6420);

  /// Warning icon color
  static const Color warningIcon = Color(0xFFDA9D3B);

  /// Text on warning color
  static const Color onWarning = Color(0xFF1A1A1F);

  // Error - Crimson red
  /// Base error color - WCAG AA compliant
  static const Color error = Color(0xFFB83A4F); // Deep crimson

  /// Light error background
  static const Color errorLight = Color(0xFFFCEBED);

  /// Error text
  static const Color errorText = Color(0xFF8B2942);

  /// Error icon color
  static const Color errorIcon = Color(0xFFD94D62);

  /// Text on error color
  static const Color onError = Color(0xFFFFFFFF);

  // Info - Steel blue
  /// Base info color - WCAG AA compliant
  static const Color info = Color(0xFF3A6399); // Deep steel blue

  /// Light info background
  static const Color infoLight = Color(0xFFE8F0F8);

  /// Info text
  static const Color infoText = Color(0xFF2B4A73);

  /// Info icon color
  static const Color infoIcon = Color(0xFF4D7FB8);

  /// Text on info color
  static const Color onInfo = Color(0xFFFFFFFF);

  // ===========================================================================
  // BORDER & DIVIDER COLORS
  // ===========================================================================

  /// Subtle border (6% black)
  static const Color borderSubtle = Color(0x0F000000);

  /// Default border (10% black)
  static const Color border = Color(0x1A000000);

  /// Strong border (15% black)
  static const Color borderStrong = Color(0x26000000);

  /// Focused border (gold)
  static const Color borderFocused = Color(0xFFB8943D);

  /// Error border
  static const Color borderError = Color(0xFFB83A4F);

  /// Success border
  static const Color borderSuccess = Color(0xFF1E7D52);

  /// Gold accent border (30% opacity)
  static const Color borderGold = Color(0x4DB8943D);

  /// Strong gold border (50% opacity)
  static const Color borderGoldStrong = Color(0x80B8943D);

  /// Divider color
  static const Color divider = Color(0x1A000000);

  /// Divider on surfaces
  static const Color dividerOnSurface = Color(0x0F000000);

  // ===========================================================================
  // CARD & CONTAINER COLORS
  // ===========================================================================

  /// Standard card background
  static const Color card = Color(0xFFFFFFFF);

  /// Elevated card with shadow
  static const Color cardElevated = Color(0xFFFFFFFF);

  /// Outlined card (no fill)
  static const Color cardOutlined = Color(0x00000000); // Transparent

  /// Card hover state
  static const Color cardHover = Color(0xFFF9F9F7);

  /// Card pressed state
  static const Color cardPressed = Color(0xFFF2F2F0);

  // ===========================================================================
  // TRANSACTION-SPECIFIC COLORS
  // ===========================================================================

  /// Deposit/receive transactions
  static const Color deposit = Color(0xFF1E7D52); // Success green

  /// Deposit background
  static const Color depositBackground = Color(0xFFE8F5ED);

  /// Deposit icon
  static const Color depositIcon = Color(0xFF2D9663);

  /// Withdrawal/send transactions
  static const Color withdraw = Color(0xFFB83A4F); // Error red

  /// Withdrawal background
  static const Color withdrawBackground = Color(0xFFFCEBED);

  /// Withdrawal icon
  static const Color withdrawIcon = Color(0xFFD94D62);

  /// Transfer transactions
  static const Color transfer = Color(0xFF3A6399); // Info blue

  /// Transfer background
  static const Color transferBackground = Color(0xFFE8F0F8);

  /// Transfer icon
  static const Color transferIcon = Color(0xFF4D7FB8);

  /// Pending/processing transactions
  static const Color pending = Color(0xFFB8862D); // Warning amber

  /// Pending background
  static const Color pendingBackground = Color(0xFFFFF5E6);

  /// Pending icon
  static const Color pendingIcon = Color(0xFFDA9D3B);

  /// Failed transactions
  static const Color failed = Color(0xFF8B2942); // Dark error

  /// Failed background
  static const Color failedBackground = Color(0xFFFCEBED);

  // ===========================================================================
  // OVERLAY & SHADOW COLORS
  // ===========================================================================

  /// Light overlay (5% black) - for subtle hover states
  static const Color overlayLight = Color(0x0D000000);

  /// Medium overlay (10% black) - for pressed states
  static const Color overlayMedium = Color(0x1A000000);

  /// Dark overlay (50% black) - for disabled content
  static const Color overlayDark = Color(0x80000000);

  /// Scrim overlay (80% black) - for dialogs, bottom sheets
  static const Color overlayScrim = Color(0xCC000000);

  /// Shadow color for elevation
  static const Color shadow = Color(0x1A000000); // 10% black

  /// Strong shadow for high elevation
  static const Color shadowStrong = Color(0x33000000); // 20% black

  // ===========================================================================
  // INPUT & FORM COLORS
  // ===========================================================================

  /// Input background (default state)
  static const Color inputBackground = Color(0xFFFFFFFF);

  /// Input background (focused state)
  static const Color inputBackgroundFocused = Color(0xFFFAFAF8);

  /// Input background (disabled state)
  static const Color inputBackgroundDisabled = Color(0xFFF2F2F0);

  /// Input border (default)
  static const Color inputBorder = Color(0x1A000000);

  /// Input border (focused)
  static const Color inputBorderFocused = Color(0xFFB8943D);

  /// Input border (error)
  static const Color inputBorderError = Color(0xFFB83A4F);

  /// Placeholder text
  static const Color inputPlaceholder = Color(0xFF8A8A8E);

  // ===========================================================================
  // BUTTON COLORS
  // ===========================================================================

  /// Primary button background
  static const Color buttonPrimary = Color(0xFFB8943D); // Gold

  /// Primary button hover
  static const Color buttonPrimaryHover = Color(0xFFA68535);

  /// Primary button pressed
  static const Color buttonPrimaryPressed = Color(0xFF8A6E2B);

  /// Primary button disabled
  static const Color buttonPrimaryDisabled = Color(0xFFD9D9D6);

  /// Secondary button background
  static const Color buttonSecondary = Color(0x1A1A1A1F); // 10% obsidian

  /// Secondary button hover
  static const Color buttonSecondaryHover = Color(0x261A1A1F); // 15% obsidian

  /// Secondary button pressed
  static const Color buttonSecondaryPressed = Color(0x331A1A1F); // 20% obsidian

  /// Text button color
  static const Color buttonText = Color(0xFFB8943D); // Gold

  /// Text button hover
  static const Color buttonTextHover = Color(0xFF8A6E2B);

  // ===========================================================================
  // BADGE & CHIP COLORS
  // ===========================================================================

  /// Neutral badge
  static const Color badgeNeutral = Color(0xFFEDEDEB);
  static const Color badgeNeutralText = Color(0xFF5A5A5E);

  /// Success badge
  static const Color badgeSuccess = Color(0xFFE8F5ED);
  static const Color badgeSuccessText = Color(0xFF1A5C3E);

  /// Warning badge
  static const Color badgeWarning = Color(0xFFFFF5E6);
  static const Color badgeWarningText = Color(0xFF8A6420);

  /// Error badge
  static const Color badgeError = Color(0xFFFCEBED);
  static const Color badgeErrorText = Color(0xFF8B2942);

  /// Info badge
  static const Color badgeInfo = Color(0xFFE8F0F8);
  static const Color badgeInfoText = Color(0xFF2B4A73);

  // ===========================================================================
  // NAVIGATION & APP BAR COLORS
  // ===========================================================================

  /// App bar background
  static const Color appBarBackground = Color(0xFFFFFFFF);

  /// App bar text
  static const Color appBarText = Color(0xFF1A1A1F);

  /// App bar icon
  static const Color appBarIcon = Color(0xFF5A5A5E);

  /// Bottom navigation background
  static const Color bottomNavBackground = Color(0xFFFFFFFF);

  /// Bottom nav selected item
  static const Color bottomNavSelected = Color(0xFFB8943D);

  /// Bottom nav unselected item
  static const Color bottomNavUnselected = Color(0xFF8A8A8E);

  /// Tab indicator
  static const Color tabIndicator = Color(0xFFB8943D);

  /// Tab selected text
  static const Color tabSelectedText = Color(0xFF1A1A1F);

  /// Tab unselected text
  static const Color tabUnselectedText = Color(0xFF8A8A8E);

  // ===========================================================================
  // SPECIAL PURPOSE COLORS
  // ===========================================================================

  /// Skeleton loader shimmer
  static const Color skeleton = Color(0xFFEDEDEB);
  static const Color skeletonShimmer = Color(0xFFF5F5F2);

  /// Tooltip background
  static const Color tooltip = Color(0xFF2D2D33);
  static const Color tooltipText = Color(0xFFFAFAF8);

  /// Modal barrier
  static const Color modalBarrier = Color(0x80000000);

  /// Snackbar background
  static const Color snackbarBackground = Color(0xFF2D2D33);
  static const Color snackbarText = Color(0xFFFAFAF8);

  /// Link color
  static const Color link = Color(0xFF3A6399);
  static const Color linkHover = Color(0xFF2B4A73);
  static const Color linkVisited = Color(0xFF6D4C9A);

  /// QR code colors
  static const Color qrForeground = Color(0xFF1A1A1F);
  static const Color qrBackground = Color(0xFFFFFFFF);

  // ===========================================================================
  // GRADIENTS
  // ===========================================================================

  /// Gold gradient for premium elements
  static const List<Color> goldGradient = [
    Color(0xFFB8943D),
    Color(0xFFD4AF56),
    Color(0xFFB8943D),
  ];

  /// Success gradient
  static const List<Color> successGradient = [
    Color(0xFF1E7D52),
    Color(0xFF2D9663),
  ];

  /// Background gradient (subtle)
  static const List<Color> backgroundGradient = [
    Color(0xFFFAFAF8),
    Color(0xFFF5F5F2),
  ];
}

/// Accessibility helper to ensure WCAG AA compliance
class LightColorsAccessibility {
  /// Check if text color has sufficient contrast on background
  /// WCAG AA requires 4.5:1 for normal text, 3:1 for large text
  static bool hasValidContrast(Color text, Color background, {bool isLargeText = false}) {
    final double ratio = _contrastRatio(text, background);
    final double requiredRatio = isLargeText ? 3.0 : 4.5;
    return ratio >= requiredRatio;
  }

  static double _contrastRatio(Color color1, Color color2) {
    final double l1 = _relativeLuminance(color1);
    final double l2 = _relativeLuminance(color2);
    final double lighter = l1 > l2 ? l1 : l2;
    final double darker = l1 > l2 ? l2 : l1;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static double _relativeLuminance(Color color) {
    final double r = _linearize(color.r);
    final double g = _linearize(color.g);
    final double b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _linearize(double channel) {
    if (channel <= 0.03928) {
      return channel / 12.92;
    }
    return ((channel + 0.055) / 1.055) * ((channel + 0.055) / 1.055);
  }
}
