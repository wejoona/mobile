import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';

/// Empty state component for no data scenarios
/// Themed for both light and dark modes
///
/// Usage:
/// ```dart
/// EmptyState(
///   icon: Icons.inbox_outlined,
///   title: 'No transactions',
///   description: 'Your transaction history will appear here',
///   action: EmptyStateAction(
///     label: 'Send Money',
///     onPressed: () => context.push('/send'),
///   ),
/// )
/// ```
class EmptyState extends StatelessWidget {
  const EmptyState({
    required this.icon,
    required this.title,
    super.key,
    this.description,
    this.action,
    this.customIllustration,
    this.padding,
  });

  /// Icon to display (will be themed)
  final IconData icon;

  /// Main title text
  final String title;

  /// Optional description text
  final String? description;

  /// Optional action button
  final EmptyStateAction? action;

  /// Custom illustration widget (overrides icon)
  final Widget? customIllustration;

  /// Padding around the content
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final colors = _ThemeColors.of(context);
    final effectivePadding =
        padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.xxl);

    return Semantics(
      label: '$title. ${description ?? ''}',
      container: true,
      child: Center(
        child: Padding(
          padding: effectivePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Illustration or Icon
              _buildIllustration(colors),
              const SizedBox(height: AppSpacing.xl),

              // Title
              Text(
                title,
                style: AppTypography.titleLarge.copyWith(
                  color: colors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),

              // Description
              if (description != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  description!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              // Action button
              if (action != null) ...[
                const SizedBox(height: AppSpacing.xxl),
                _buildActionButton(colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIllustration(_ThemeColors colors) {
    if (customIllustration != null) {
      return customIllustration!;
    }

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colors.elevated,
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.borderSubtle,
          width: 1,
        ),
      ),
      child: Icon(
        icon,
        size: 40,
        color: colors.iconSecondary,
      ),
    );
  }

  Widget _buildActionButton(_ThemeColors colors) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: action!.onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.gold,
          foregroundColor: colors.textInverse,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
        child: Text(
          action!.label,
          style: AppTypography.button,
        ),
      ),
    );
  }
}

/// Action button configuration for empty state
class EmptyStateAction {
  const EmptyStateAction({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
}

/// Pre-built empty state variants for common scenarios
class EmptyStateVariant {
  /// No transactions
  static Widget noTransactions({
    required String title,
    String? description,
    EmptyStateAction? action,
  }) {
    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: title,
      description: description,
      action: action,
    );
  }

  /// No search results
  static Widget noSearchResults({
    required String title,
    String? description,
    VoidCallback? onClear,
  }) {
    return EmptyState(
      icon: Icons.search_off_outlined,
      title: title,
      description: description,
      action: onClear != null
          ? EmptyStateAction(
              label: 'Clear Search',
              onPressed: onClear,
            )
          : null,
    );
  }

  /// No beneficiaries
  static Widget noBeneficiaries({
    required String title,
    String? description,
    VoidCallback? onAdd,
  }) {
    return EmptyState(
      icon: Icons.people_outline,
      title: title,
      description: description,
      action: onAdd != null
          ? EmptyStateAction(
              label: 'Add Beneficiary',
              onPressed: onAdd,
            )
          : null,
    );
  }

  /// No notifications
  static Widget noNotifications({
    required String title,
    String? description,
  }) {
    return EmptyState(
      icon: Icons.notifications_none_outlined,
      title: title,
      description: description,
    );
  }

  /// Network error (for offline state)
  static Widget networkError({
    required String title,
    String? description,
    VoidCallback? onRetry,
  }) {
    return EmptyState(
      icon: Icons.wifi_off_outlined,
      title: title,
      description: description,
      action: onRetry != null
          ? EmptyStateAction(
              label: 'Retry',
              onPressed: onRetry,
            )
          : null,
    );
  }
}

/// Theme-aware colors helper
class _ThemeColors {
  final bool isDark;

  const _ThemeColors._({required this.isDark});

  factory _ThemeColors.of(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return _ThemeColors._(isDark: brightness == Brightness.dark);
  }

  Color get textPrimary =>
      isDark ? AppColors.textPrimary : AppColorsLight.textPrimary;
  Color get textSecondary =>
      isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get textInverse =>
      isDark ? AppColors.textInverse : AppColorsLight.textInverse;
  Color get elevated => isDark ? AppColors.elevated : AppColorsLight.elevated;
  Color get borderSubtle =>
      isDark ? AppColors.borderSubtle : AppColorsLight.borderSubtle;
  Color get iconSecondary =>
      isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
  Color get gold => isDark ? AppColors.gold500 : AppColorsLight.gold500;
}
