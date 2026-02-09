import 'package:flutter/material.dart';
import '../../tokens/index.dart';
import '../primitives/index.dart';

/// Confirmation dialog with customizable actions
///
/// Specialized dialog for destructive or important actions that require
/// user confirmation. Provides visual emphasis based on action severity.
///
/// Usage:
/// ```dart
/// final confirmed = await ConfirmationDialog.show(
///   context,
///   title: 'Delete Transaction',
///   message: 'This will permanently delete the transaction. This action cannot be undone.',
///   confirmText: 'Delete',
///   isDestructive: true,
/// );
///
/// if (confirmed) {
///   // Perform delete action
/// }
/// ```
class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.icon,
    this.details,
  });

  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final IconData? icon;
  final Widget? details;

  /// Show confirmation dialog
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Widget? details,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: context.colors.scrim,
      barrierDismissible: !isDestructive,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        icon: icon,
        details: details,
      ),
    );

    return result ?? false;
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

            // Optional details section
            if (details != null) ...[
              const SizedBox(height: AppSpacing.lg),
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: colors.elevated,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: colors.borderSubtle,
                    width: 1,
                  ),
                ),
                child: details,
              ),
            ],

            const SizedBox(height: AppSpacing.xl),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: cancelText,
                    onPressed: () => Navigator.pop(context, false),
                    variant: AppButtonVariant.secondary,
                    size: AppButtonSize.medium,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppButton(
                    label: confirmText,
                    onPressed: () => Navigator.pop(context, true),
                    variant: isDestructive
                        ? AppButtonVariant.danger
                        : AppButtonVariant.primary,
                    size: AppButtonSize.medium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, ThemeColors colors) {
    final iconColor = isDestructive ? colors.error : colors.warning;
    final iconData = icon ??
        (isDestructive ? Icons.delete_outline : Icons.warning_amber_outlined);
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
}

/// Extension to show confirmation dialogs from any BuildContext
extension ConfirmationDialogExtension on BuildContext {
  /// Show a confirmation dialog
  Future<bool> showConfirmation({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    IconData? icon,
    Widget? details,
  }) {
    return ConfirmationDialog.show(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: isDestructive,
      icon: icon,
      details: details,
    );
  }

  /// Show a delete confirmation dialog
  Future<bool> showDeleteConfirmation({
    required String title,
    required String message,
    String confirmText = 'Delete',
    String cancelText = 'Cancel',
  }) {
    return ConfirmationDialog.show(
      this,
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      isDestructive: true,
      icon: Icons.delete_outline,
    );
  }
}
