import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/services/bill_payments/bill_payments_service.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Bill Provider Card Widget
class ProviderCard extends StatelessWidget {
  const ProviderCard({
    super.key,
    required this.provider,
    required this.onTap,
    this.isSelected = false,
  });

  final BillProvider provider;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Provider Logo
            _ProviderLogo(
              logoUrl: provider.logo,
              name: provider.shortName,
            ),
            const SizedBox(width: AppSpacing.md),

            // Provider Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    provider.name,
                    variant: AppTextVariant.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _CategoryBadge(category: provider.category),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        provider.estimatedProcessingTime,
                        variant: AppTextVariant.labelSmall,
                        color: colors.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    _formatFee(context),
                    variant: AppTextVariant.labelSmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: isSelected ? colors.gold : colors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _formatFee(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (provider.processingFee == 0) {
      return l10n.billPayments_feeNone;
    }
    if (provider.processingFeeType == 'percentage') {
      return l10n.billPayments_feePercentage(provider.processingFee.toString());
    }
    return l10n.billPayments_feeFixed(provider.processingFee.toInt(), provider.currency);
  }
}

/// Compact Provider Card for selection lists
class ProviderCardCompact extends StatelessWidget {
  const ProviderCardCompact({
    super.key,
    required this.provider,
    required this.onTap,
    this.isSelected = false,
  });

  final BillProvider provider;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? colors.gold.withValues(alpha: 0.1) : colors.container,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? colors.gold : colors.borderSubtle,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _ProviderLogo(
              logoUrl: provider.logo,
              name: provider.shortName,
              size: 40,
            ),
            const SizedBox(height: AppSpacing.xs),
            AppText(
              provider.shortName,
              variant: AppTextVariant.labelSmall,
              color: isSelected ? colors.gold : colors.textPrimary,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Provider Logo with fallback
class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({
    required this.logoUrl,
    required this.name,
    this.size = 48,
  });

  final String logoUrl;
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (logoUrl.isEmpty) {
      return _buildFallback(context);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (ctx, url) => _buildFallback(ctx),
        errorWidget: (ctx, url, error) => _buildFallback(ctx),
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.gold.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: AppText(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          variant: AppTextVariant.titleMedium,
          color: colors.gold,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Category Badge
class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});

  final BillCategory category;

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        category.displayName,
        variant: AppTextVariant.labelSmall,
        color: categoryColor,
      ),
    );
  }

  Color _getCategoryColor(BuildContext context) {
    final colors = context.colors;
    switch (category) {
      case BillCategory.electricity:
        return const Color(0xFFF0C674); // Yellow
      case BillCategory.water:
        return colors.infoText; // Blue
      case BillCategory.internet:
        return const Color(0xFFB294D1); // Purple
      case BillCategory.tv:
        return const Color(0xFF7DD3D8); // Cyan
      case BillCategory.phoneCredit:
        return colors.successText; // Green
      case BillCategory.insurance:
        return colors.gold; // Gold
      case BillCategory.education:
        return colors.infoText; // Blue
      case BillCategory.government:
        return colors.textSecondary; // Silver
    }
  }
}

/// Provider List Item for history
class ProviderListItem extends StatelessWidget {
  const ProviderListItem({
    super.key,
    required this.payment,
    required this.onTap,
  });

  final BillPaymentHistoryItem payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.container,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: colors.borderSubtle, width: 1),
        ),
        child: Row(
          children: [
            // Provider Logo
            _ProviderLogo(
              logoUrl: payment.providerLogo,
              name: payment.providerName,
              size: 44,
            ),
            const SizedBox(width: AppSpacing.md),

            // Payment Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    payment.providerName,
                    variant: AppTextVariant.bodyMedium,
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    payment.accountNumber,
                    variant: AppTextVariant.labelSmall,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),

            // Amount and Status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  '${payment.totalAmount.toStringAsFixed(0)} ${payment.currency}',
                  variant: AppTextVariant.bodyMedium,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
                const SizedBox(height: 2),
                _StatusBadge(status: payment.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Status Badge
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        _getStatusText(context),
        variant: AppTextVariant.labelSmall,
        color: statusColor,
      ),
    );
  }

  Color _getStatusColor(BuildContext context) {
    final colors = context.colors;
    switch (status) {
      case 'completed':
        return colors.successText;
      case 'pending':
      case 'processing':
        return colors.warningText;
      case 'failed':
      case 'refunded':
        return colors.errorText;
      default:
        return colors.textSecondary;
    }
  }

  String _getStatusText(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case 'completed':
        return l10n.billPayments_statusCompleted;
      case 'pending':
        return l10n.billPayments_statusPending;
      case 'processing':
        return l10n.billPayments_statusProcessing;
      case 'failed':
        return l10n.billPayments_statusFailed;
      case 'refunded':
        return l10n.billPayments_statusRefunded;
      default:
        return status;
    }
  }
}
