import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import '../primitives/index.dart';

/// Dialog types for different visual treatments
enum DialogType {
  info,
  success,
  warning,
  error,
}

/// Base themed dialog component
///
/// Provides consistent styling for dialogs across light and dark themes.
/// Use static methods for common dialog patterns, or use the widget directly.
///
/// Usage:
/// ```dart
/// // Using static method
/// final confirmed = await AppDialog.confirm(
///   context,
///   title: 'Delete Account',
///   message: 'This action cannot be undone.',
/// );
///
/// // Using widget directly
/// showDialog(
///   context: context,
///   builder: (context) => AppDialog(
///     title: 'Custom Dialog',
///     content: MyCustomWidget(),
///   ),
/// );
/// ```
class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    this.title,
    this.titleWidget,
    this.content,
    this.contentWidget,
    this.actions,
    this.type = DialogType.info,
    this.showIcon = true,
    this.icon,
    this.dismissible = true,
  });

  final String? title;
  final Widget? titleWidget;
  final String? content;
  final Widget? contentWidget;
  final List<Widget>? actions;
  final DialogType type;
  final bool showIcon;
  final IconData? icon;
  final bool dismissible;

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
            if (showIcon) ...[
              _buildIcon(context, colors),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Title
            if (titleWidget != null)
              titleWidget!
            else if (title != null) ...[
              AppText(
                title!,
                variant: AppTextVariant.titleLarge,
                color: colors.textPrimary,
                textAlign: TextAlign.center,
              ),
            ],

            // Content
            if (contentWidget != null || content != null) ...[
              const SizedBox(height: AppSpacing.md),
              if (contentWidget != null)
                contentWidget!
              else if (content != null)
                AppText(
                  content!,
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
            ],

            // Actions
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              _buildActions(),
            ],
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

  Widget _buildActions() {
    if (actions!.length == 1) {
      return SizedBox(
        width: double.infinity,
        child: actions!.first,
      );
    }

    return Row(
      children: [
        Expanded(child: actions![0]),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: actions![1]),
      ],
    );
  }

  Color _getIconColor(ThemeColors colors) {
    switch (type) {
      case DialogType.success:
        return colors.success;
      case DialogType.warning:
        return colors.warning;
      case DialogType.error:
        return colors.error;
      case DialogType.info:
        return colors.gold;
    }
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case DialogType.success:
        return Icons.check_circle_outline;
      case DialogType.warning:
        return Icons.warning_amber_outlined;
      case DialogType.error:
        return Icons.error_outline;
      case DialogType.info:
        return Icons.info_outline;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STATIC HELPER METHODS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Show a basic alert dialog
  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
    DialogType type = DialogType.info,
    bool showIcon = true,
    IconData? icon,
  }) {
    final colors = context.colors;

    return showDialog(
      context: context,
      barrierColor: colors.scrim,
      builder: (context) => AppDialog(
        title: title,
        content: message,
        type: type,
        showIcon: showIcon,
        icon: icon,
        actions: [
          AppButton(
            label: buttonText ?? 'OK',
            onPressed: () => Navigator.pop(context),
            size: AppButtonSize.medium,
          ),
        ],
      ),
    );
  }

  /// Show a confirmation dialog with yes/no buttons
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmText,
    String? cancelText,
    DialogType type = DialogType.warning,
    bool showIcon = true,
    IconData? icon,
  }) async {
    final colors = context.colors;

    final result = await showDialog<bool>(
      context: context,
      barrierColor: colors.scrim,
      builder: (context) => AppDialog(
        title: title,
        content: message,
        type: type,
        showIcon: showIcon,
        icon: icon,
        actions: [
          AppButton(
            label: cancelText ?? 'Cancel',
            onPressed: () => Navigator.pop(context, false),
            variant: AppButtonVariant.secondary,
            size: AppButtonSize.medium,
          ),
          AppButton(
            label: confirmText ?? 'Confirm',
            onPressed: () => Navigator.pop(context, true),
            size: AppButtonSize.medium,
            variant: type == DialogType.error
                ? AppButtonVariant.danger
                : AppButtonVariant.primary,
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Show a success dialog
  static Future<void> success(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: DialogType.success,
    );
  }

  /// Show an error dialog
  static Future<void> error(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: DialogType.error,
    );
  }

  /// Show a warning dialog
  static Future<void> warning(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: DialogType.warning,
    );
  }

  /// Show an info dialog
  static Future<void> info(
    BuildContext context, {
    required String title,
    required String message,
    String? buttonText,
  }) {
    return show(
      context,
      title: title,
      message: message,
      buttonText: buttonText,
      type: DialogType.info,
    );
  }
}
