import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/accessibility_utils.dart';
import '../../../utils/accessibility_enhancements.dart';

/// Example of accessibility-enhanced Wallet Home components
///
/// This file demonstrates how to add proper accessibility to wallet home screen
/// components. Use these patterns when creating or updating wallet UI.

/// Enhanced Balance Card with Accessibility
class AccessibleBalanceCard extends StatelessWidget {
  const AccessibleBalanceCard({
    super.key,
    required this.balance,
    required this.isHidden,
    required this.onToggleVisibility,
  });

  final double balance;
  final bool isHidden;
  final VoidCallback onToggleVisibility;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    // Generate semantic label for the entire balance card
    final semanticLabel = WalletAccessibility.balanceLabel(
      balance,
      isHidden: isHidden,
    );

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.container,
              colors.container.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          border: Border.all(
            color: colors.borderGold.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.cardPaddingLarge),
          child: Column(
            children: [
              // Header row with label and visibility toggle
              Row(
                children: [
                  // Icon is decorative, exclude from semantics
                  ExcludeSemantics(
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: colors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Label is already announced in container semantics
                  ExcludeSemantics(
                    child: AppText(
                      l10n.home_totalBalance,
                      variant: AppTextVariant.bodyMedium,
                      color: colors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  // Visibility toggle with proper semantics
                  Semantics(
                    label: WalletAccessibility.balanceVisibilityLabel(isHidden),
                    hint: WalletAccessibility.balanceVisibilityHint(isHidden),
                    button: true,
                    excludeSemantics: true,
                    child: IconButton(
                      onPressed: onToggleVisibility,
                      icon: Icon(
                        isHidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: colors.textTertiary,
                        size: 20,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  // Badge is decorative
                  ExcludeSemantics(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xxs,
                      ),
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: AppText(
                        'USDC',
                        variant: AppTextVariant.labelSmall,
                        color: colors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Balance amount with semantic label
              Center(
                child: isHidden
                    ? ExcludeSemantics(
                        child: AppText(
                          '••••••',
                          variant: AppTextVariant.displayLarge,
                          color: colors.gold,
                        ),
                      )
                    : AppText(
                        '\$${_formatBalance(balance)}',
                        variant: AppTextVariant.displayLarge,
                        color: colors.gold,
                        semanticLabel: AccessibilityUtils.formatCurrencyForScreenReader(balance),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatBalance(double amount) {
    if (amount >= 1000000) {
      final millions = amount / 1000000;
      return '${millions.toStringAsFixed(2)}M';
    } else if (amount >= 1000) {
      final thousands = amount / 1000;
      return '${thousands.toStringAsFixed(2)}K';
    }
    return amount.toStringAsFixed(2);
  }
}

/// Enhanced Quick Action Button with Accessibility
class AccessibleQuickActionButton extends StatelessWidget {
  const AccessibleQuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String action; // Description of what the button does
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: label,
      hint: 'Double tap to $action',
      button: true,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.lg,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colors.container,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.borderSubtle),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colors.gold.withValues(alpha: 0.2),
                        colors.gold.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(icon, color: colors.gold, size: 24),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ExcludeSemantics(
                child: AppText(
                  label,
                  variant: AppTextVariant.labelSmall,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Enhanced Transaction Row with Accessibility
class AccessibleTransactionRow extends StatelessWidget {
  const AccessibleTransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.isIncoming,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final bool isIncoming;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    // Generate comprehensive semantic label
    final semanticLabel = WalletAccessibility.transactionLabel(
      title: title,
      amount: amount,
      date: date,
      isIncoming: isIncoming,
    );

    return Semantics(
      label: semanticLabel,
      button: true,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              // Icon indicates direction - decorative
              ExcludeSemantics(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isIncoming
                        ? colors.success.withValues(alpha: 0.15)
                        : colors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Icon(
                    isIncoming ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncoming ? colors.successText : colors.gold,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),

              // Transaction details - excluded since parent has label
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        title,
                        variant: AppTextVariant.bodyLarge,
                        color: colors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        subtitle,
                        variant: AppTextVariant.bodySmall,
                        color: colors.textTertiary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // Amount - excluded since parent has label
              ExcludeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    AppText(
                      '${isIncoming ? '+' : '-'}\$${amount.toStringAsFixed(2)}',
                      variant: AppTextVariant.titleSmall,
                      color: isIncoming ? colors.successText : colors.textPrimary,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    AppText(
                      _formatDate(date),
                      variant: AppTextVariant.bodySmall,
                      color: colors.textTertiary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.month}/${date.day}';
    }
  }
}

/// Example: Enhanced notification icon with badge
class AccessibleNotificationIcon extends StatelessWidget {
  const AccessibleNotificationIcon({
    super.key,
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasUnread = unreadCount > 0;

    final label = hasUnread
        ? 'Notifications, $unreadCount unread'
        : 'Notifications';

    return Semantics(
      label: label,
      hint: 'Double tap to view notifications',
      button: true,
      excludeSemantics: true,
      child: IconButton(
        onPressed: onTap,
        icon: Stack(
          children: [
            Icon(
              Icons.notifications_outlined,
              color: colors.textSecondary,
            ),
            if (hasUnread)
              Positioned(
                right: 0,
                top: 0,
                child: ExcludeSemantics(
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: colors.error,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Center(
                      child: Text(
                        unreadCount > 9 ? '9+' : '$unreadCount',
                        style: TextStyle(
                          color: colors.textInverse,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Example: Accessible loading state
class AccessibleLoadingState extends StatelessWidget {
  const AccessibleLoadingState({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      label: message,
      liveRegion: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: CircularProgressIndicator(
                color: colors.gold,
                strokeWidth: 2,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ExcludeSemantics(
              child: AppText(
                message,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example: Accessible error state
class AccessibleErrorState extends StatelessWidget {
  const AccessibleErrorState({
    super.key,
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Semantics(
      label: 'Error: $error',
      liveRegion: true,
      container: true,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.error_outline,
                color: colors.error,
                size: 48,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ExcludeSemantics(
              child: AppText(
                error,
                variant: AppTextVariant.bodyMedium,
                color: colors.textSecondary,
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.action_retry,
                onPressed: onRetry,
                variant: AppButtonVariant.secondary,
                size: AppButtonSize.small,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
