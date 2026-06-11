import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

enum AppSnackTone { neutral, success, error, warning, info }

/// BuildContext extension methods for convenient access to common properties.
extension ContextExtensions on BuildContext {
  // ── Theme ──
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  bool get isDark => theme.brightness == Brightness.dark;

  // ── Media Query ──
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  double get bottomPadding => padding.bottom;
  double get topPadding => padding.top;
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  // ── Responsive breakpoints ──
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;

  // ── Navigation ──
  NavigatorState get navigator => Navigator.of(this);
  void pop<T>([T? result]) => navigator.pop(result);
  bool get canPop => navigator.canPop();

  // ── Scaffold ──
  ScaffoldMessengerState get scaffoldMessenger => ScaffoldMessenger.of(this);

  void showSnack(
    String message, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
    AppSnackTone tone = AppSnackTone.neutral,
  }) {
    final colors = this.colors;
    final style = _snackStyle(colors, tone);

    scaffoldMessenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(style.icon, color: style.iconColor, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: style.foreground,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          duration: duration,
          behavior: SnackBarBehavior.floating,
          backgroundColor: style.background,
          elevation: isDark ? 0 : 8,
          margin: EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            bottomPadding + 88,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: style.border),
          ),
          action: action,
        ),
      );
  }

  void showErrorSnack(String message) {
    showSnack(message, tone: AppSnackTone.error);
  }

  void showSuccessSnack(String message) {
    showSnack(message, tone: AppSnackTone.success);
  }

  // ── Focus ──
  void unfocus() => FocusScope.of(this).unfocus();
}

_SnackStyle _snackStyle(ThemeColors colors, AppSnackTone tone) {
  switch (tone) {
    case AppSnackTone.success:
      return _SnackStyle(
        background: colors.successBg,
        foreground: colors.successText,
        border: colors.success.withValues(alpha: 0.28),
        iconColor: colors.success,
        icon: Icons.check_circle_outline_rounded,
      );
    case AppSnackTone.error:
      return _SnackStyle(
        background: colors.errorBg,
        foreground: colors.errorText,
        border: colors.error.withValues(alpha: 0.28),
        iconColor: colors.error,
        icon: Icons.error_outline_rounded,
      );
    case AppSnackTone.warning:
      return _SnackStyle(
        background: colors.warningBg,
        foreground: colors.warningText,
        border: colors.warning.withValues(alpha: 0.30),
        iconColor: colors.warning,
        icon: Icons.warning_amber_rounded,
      );
    case AppSnackTone.info:
      return _SnackStyle(
        background: colors.infoBg,
        foreground: colors.infoText,
        border: colors.info.withValues(alpha: 0.28),
        iconColor: colors.info,
        icon: Icons.info_outline_rounded,
      );
    case AppSnackTone.neutral:
      return _SnackStyle(
        background: colors.elevated,
        foreground: colors.textPrimary,
        border: colors.border,
        iconColor: colors.iconSecondary,
        icon: Icons.notifications_none_rounded,
      );
  }
}

class _SnackStyle {
  const _SnackStyle({
    required this.background,
    required this.foreground,
    required this.border,
    required this.iconColor,
    required this.icon,
  });

  final Color background;
  final Color foreground;
  final Color border;
  final Color iconColor;
  final IconData icon;
}
