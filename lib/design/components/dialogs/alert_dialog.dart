import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Alert type for semantic styling
enum AlertType {
  info,
  success,
  warning,
  error,
}

/// Themed alert dialog for notifications and messages
///
/// Single-action dialog for showing information, success, warnings, or errors
/// to the user. Automatically styled based on alert type.
///
/// Usage:
/// ```dart
/// // Show success alert
/// await AlertDialog.success(
///   context,
///   title: 'Transfer Complete',
///   message: 'Your payment has been sent successfully.',
/// );
///
/// // Show error alert
/// await AlertDialog.error(
///   context,
///   title: 'Transfer Failed',
///   message: 'Insufficient balance. Please add funds and try again.',
/// );
///
/// // Show custom alert
/// await AlertDialog.show(
///   context,
///   title: 'Maintenance',
///   message: 'System will be under maintenance from 2AM to 4AM.',
///   type: AlertType.warning,
/// );
/// ```
class AlertDialog extends StatelessWidget {
  const AlertDialog({
    super.key,
    required this.title,
    required this.message,
    this.type = AlertType.info,
    this.buttonText = 'OK',
    this.icon,
    this.onPressed,
  });

  final String title;
  final String message;
  final AlertType type;
  final String buttonText;
  final IconData? icon;
  final VoidCallback? onPressed;

  /// Show an alert dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    AlertType type = AlertType.info,
    String buttonText = 'OK',
    IconData? icon,
    VoidCallback? onPressed,
  }) {
    final colors = context.colors;

    return showDialog(
      context: context,
      barrierColor: colors.scrim,
      builder: (context) => AlertDialog(
        title: title,
        message: message,
        type: type,
        buttonText: buttonText,
        icon: icon,
        onPressed: onPressed,
      ),
    );
  }

  /// Show a success alert
  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.success,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Show an error alert
  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.error,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Show a warning alert
  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.warning,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  /// Show an info alert
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    return show(
      context,
      title: title,
      message: message,
      type: AlertType.info,
      buttonText: buttonText,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.container,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xxl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            _buildIcon(context, colors),
            const SizedBox(height: AppSpacing.lg),

            // Title
            AppText(
              title,
              variant: AppTextVariant.titleLarge,
              color: colors.textPrimary,
              textAlign: TextAlign.center,
            ),

            // Message
            const SizedBox(height: AppSpacing.md),
            AppText(
              message,
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.xl),

            // Action button
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: buttonText,
                onPressed: () {
                  Navigator.pop(context);
                  onPressed?.call();
                },
                size: AppButtonSize.medium,
                variant: _getButtonVariant(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ThemeColors colors) {
    final iconColor = _getIconColor(colors);
    final iconData = icon ?? _getDefaultIcon();
    final bgColor = iconColor.withValues(alpha: 0.1);

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 32,
      ),
    );
  }

  Color _getIconColor(ThemeColors colors) {
    switch (type) {
      case AlertType.success:
        return colors.success;
      case AlertType.warning:
        return colors.warning;
      case AlertType.error:
        return colors.error;
      case AlertType.info:
        return colors.gold;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case AlertType.success:
        return Icons.check_circle_outline;
      case AlertType.warning:
        return Icons.warning_amber_outlined;
      case AlertType.error:
        return Icons.error_outline;
      case AlertType.info:
        return Icons.info_outline;
    }
  }

  AppButtonVariant _getButtonVariant() {
    switch (type) {
      case AlertType.error:
        return AppButtonVariant.danger;
      case AlertType.success:
        return AppButtonVariant.primary;
      case AlertType.warning:
      case AlertType.info:
        return AppButtonVariant.primary;
    }
  }
}

/// Extension to show alerts from any BuildContext
extension AlertDialogExtension on BuildContext {
  /// Show a success alert
  Future<void> showSuccessAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return AlertDialog.success(
      this,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Show an error alert
  Future<void> showErrorAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return AlertDialog.error(
      this,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Show a warning alert
  Future<void> showWarningAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return AlertDialog.warning(
      this,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }

  /// Show an info alert
  Future<void> showInfoAlert({
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    return AlertDialog.info(
      this,
      title: title,
      message: message,
      buttonText: buttonText,
    );
  }
}
