import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/enums/index.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

/// Transaction Types
enum TransactionDisplayType {
  deposit,
  withdrawal,
  transferIn,
  transferOut,
  reward,
  neutral,
}

/// Single Transaction Row
class TransactionRow extends StatelessWidget {
  const TransactionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.type,
    this.status,
    this.icon,
    this.iconUrl,
    this.onTap,
    this.showDivider = false,
    this.currencyCode = 'USDC',
  });

  final String title;
  final String subtitle;
  final double amount;
  final DateTime date;
  final TransactionDisplayType type;
  final TransactionStatus? status;
  final IconData? icon;
  final String? iconUrl;
  final VoidCallback? onTap;
  final bool showDivider;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  // Icon
                  _buildIcon(colors),
                  const SizedBox(width: AppSpacing.md),

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: AppText(
                                title,
                                variant: AppTextVariant.bodyLarge,
                                color: colors.textPrimary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (_showStatusBadge) ...[
                              const SizedBox(width: AppSpacing.sm),
                              _buildStatusBadge(context),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        AppText(
                          subtitle,
                          variant: AppTextVariant.bodySmall,
                          color: colors.textTertiary,
                        ),
                      ],
                    ),
                  ),

                  // Amount and date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      AmountText.fromText(
                        _formatAmount(),
                        size: AmountTextSize.small,
                        color: _getAmountColor(colors),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        _formatDate(context),
                        variant: AppTextVariant.bodySmall,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: colors.borderSubtle,
            // Indent to align with the text column after the icon.
            indent: AppSpacing.lg + 44 + AppSpacing.md,
          ),
      ],
    );
  }

  bool get _showStatusBadge =>
      status != null &&
      (status == TransactionStatus.pending ||
          status == TransactionStatus.processing ||
          status == TransactionStatus.failed);

  Widget _buildStatusBadge(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    StatusTone tone;
    String label;

    switch (status) {
      case TransactionStatus.pending:
      case TransactionStatus.processing:
        tone = StatusTone.warning;
        label = l10n.transaction_pending;
        break;
      case TransactionStatus.failed:
        tone = StatusTone.danger;
        label = l10n.transaction_failed;
        break;
      case TransactionStatus.completed:
        tone = StatusTone.success;
        label = l10n.transaction_completed;
        break;
      default:
        return const SizedBox.shrink();
    }

    return StatusPill(label: label, tone: tone, compact: true);
  }

  Widget _buildIcon(ThemeColors colors) {
    final iconColor = _getIconColor(colors);
    final backgroundColor = _getIconBackgroundColor(iconColor, colors);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: iconUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: Image.network(
                iconUrl!,
                width: 24,
                height: 24,
                errorBuilder: (_, __, ___) => _buildFallbackIcon(iconColor),
              ),
            )
          : _buildFallbackIcon(iconColor),
    );
  }

  Widget _buildFallbackIcon(Color iconColor) {
    return Icon(icon ?? _getDefaultIcon(), color: iconColor, size: 22);
  }

  IconData _getDefaultIcon() {
    switch (type) {
      case TransactionDisplayType.deposit:
        return Icons.arrow_downward;
      case TransactionDisplayType.withdrawal:
        return Icons.arrow_upward;
      case TransactionDisplayType.transferIn:
        return Icons.call_received;
      case TransactionDisplayType.transferOut:
        return Icons.call_made;
      case TransactionDisplayType.reward:
        return Icons.card_giftcard;
      case TransactionDisplayType.neutral:
        return Icons.receipt_long;
    }
  }

  Color _getIconColor(ThemeColors colors) {
    // Show error color for failed transactions
    if (status == TransactionStatus.failed) {
      return colors.errorText;
    }

    // Show warning color for pending transactions
    if (status == TransactionStatus.pending ||
        status == TransactionStatus.processing) {
      return colors.warningText;
    }

    // Transaction type colors
    switch (type) {
      case TransactionDisplayType.deposit:
      case TransactionDisplayType.transferIn:
        return colors.successText;
      case TransactionDisplayType.reward:
        return colors.gold;
      case TransactionDisplayType.withdrawal:
        return colors.errorText;
      case TransactionDisplayType.transferOut:
        return colors.warningText;
      case TransactionDisplayType.neutral:
        return colors.textSecondary;
    }
  }

  Color _getIconBackgroundColor(Color iconColor, ThemeColors colors) {
    // Use theme-aware opacity for icon backgrounds
    return iconColor.withValues(alpha: colors.isDark ? 0.15 : 0.1);
  }

  Color _getAmountColor(ThemeColors colors) {
    // Show muted error color for failed transactions
    if (status == TransactionStatus.failed) {
      return colors.errorText.withValues(alpha: 0.6);
    }

    // Show warning color for pending transactions
    if (status == TransactionStatus.pending ||
        status == TransactionStatus.processing) {
      return colors.warningText;
    }

    // Color based on transaction type
    switch (type) {
      case TransactionDisplayType.deposit:
      case TransactionDisplayType.transferIn:
        return colors.successText; // Green for incoming
      case TransactionDisplayType.reward:
        return colors.gold; // Gold for rewards
      case TransactionDisplayType.withdrawal:
        return colors.errorText; // Red for outgoing withdrawals
      case TransactionDisplayType.transferOut:
        return colors.warningText; // Orange/amber for sent transfers
      case TransactionDisplayType.neutral:
        return colors.textSecondary;
    }
  }

  String _formatAmount() {
    final sign = _amountSign();
    final absAmount = amount.abs();
    return '$sign${formatCurrency(absAmount, currencyCode)}';
  }

  String _amountSign() {
    switch (type) {
      case TransactionDisplayType.deposit:
      case TransactionDisplayType.transferIn:
      case TransactionDisplayType.reward:
        return '+';
      case TransactionDisplayType.withdrawal:
      case TransactionDisplayType.transferOut:
        return '-';
      case TransactionDisplayType.neutral:
        return '';
    }
  }

  String _formatDate(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return l10n.transactions_today;
    } else if (diff.inDays == 1) {
      return l10n.transactions_yesterday;
    }

    return DateFormat.MMMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).format(date);
  }
}

/// Transaction List with header
class TransactionList extends StatelessWidget {
  const TransactionList({
    super.key,
    required this.transactions,
    this.title = 'Recent Transactions',
    this.onViewAllTap,
    this.isLoading = false,
  });

  final List<TransactionRow> transactions;
  final String title;
  final VoidCallback? onViewAllTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      variant: AppCardVariant.elevated,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: colors.gold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.receipt_long_outlined,
                        color: colors.gold,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppText(
                      title,
                      variant: AppTextVariant.cardLabel,
                      color: colors.textSecondary,
                    ),
                  ],
                ),
                if (onViewAllTap != null)
                  GestureDetector(
                    onTap: onViewAllTap,
                    child: Icon(
                      Icons.more_horiz,
                      color: colors.textTertiary,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Transaction list
          if (isLoading)
            _buildLoadingState(colors)
          else if (transactions.isEmpty)
            _buildEmptyState(colors)
          else
            ...transactions,
        ],
      ),
    );
  }

  Widget _buildLoadingState(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: List.generate(3, (_) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: colors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Container(
                        width: 80,
                        height: 12,
                        decoration: BoxDecoration(
                          color: colors.elevated,
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 70,
                      height: 16,
                      decoration: BoxDecoration(
                        color: colors.elevated,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Container(
                      width: 50,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colors.elevated,
                        borderRadius: BorderRadius.circular(AppRadius.xs),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState(ThemeColors colors) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.elevated,
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              child: Icon(
                Icons.receipt_long_outlined,
                color: colors.textTertiary,
                size: 32,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppText(
              'No transactions yet',
              variant: AppTextVariant.bodyMedium,
              color: colors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
