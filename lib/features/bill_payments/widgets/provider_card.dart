import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../../../services/bill_payments/bill_payments_service.dart';

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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold500.withOpacity(0.1) : AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? AppColors.gold500 : AppColors.borderSubtle,
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
                    color: AppColors.textPrimary,
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
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  AppText(
                    _formatFee(),
                    variant: AppTextVariant.labelSmall,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),

            // Arrow
            Icon(
              Icons.chevron_right,
              color: isSelected ? AppColors.gold500 : AppColors.textTertiary,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String _formatFee() {
    if (provider.processingFee == 0) {
      return 'No fee';
    }
    if (provider.processingFeeType == 'percentage') {
      return '${provider.processingFee}% fee';
    }
    return '${provider.processingFee.toInt()} ${provider.currency} fee';
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold500.withOpacity(0.1) : AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.gold500 : AppColors.borderSubtle,
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
              color: isSelected ? AppColors.gold500 : AppColors.textPrimary,
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
      return _buildFallback();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: CachedNetworkImage(
        imageUrl: logoUrl,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => _buildFallback(),
        errorWidget: (context, url, error) => _buildFallback(),
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.gold500.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Center(
        child: AppText(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          variant: AppTextVariant.titleMedium,
          color: AppColors.gold500,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getCategoryColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        category.displayName,
        variant: AppTextVariant.labelSmall,
        color: _getCategoryColor(),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (category) {
      case BillCategory.electricity:
        return Colors.amber;
      case BillCategory.water:
        return Colors.blue;
      case BillCategory.internet:
        return Colors.purple;
      case BillCategory.tv:
        return Colors.red;
      case BillCategory.phoneCredit:
        return Colors.green;
      case BillCategory.insurance:
        return Colors.teal;
      case BillCategory.education:
        return Colors.indigo;
      case BillCategory.government:
        return Colors.grey;
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle, width: 1),
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
                    color: AppColors.textPrimary,
                  ),
                  const SizedBox(height: 2),
                  AppText(
                    payment.accountNumber,
                    variant: AppTextVariant.labelSmall,
                    color: AppColors.textSecondary,
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
                  color: AppColors.textPrimary,
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
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: AppText(
        _getStatusText(),
        variant: AppTextVariant.labelSmall,
        color: _getStatusColor(),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'completed':
        return AppColors.successText;
      case 'pending':
      case 'processing':
        return AppColors.warningText;
      case 'failed':
      case 'refunded':
        return AppColors.errorText;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getStatusText() {
    switch (status) {
      case 'completed':
        return 'Completed';
      case 'pending':
        return 'Pending';
      case 'processing':
        return 'Processing';
      case 'failed':
        return 'Failed';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }
}
