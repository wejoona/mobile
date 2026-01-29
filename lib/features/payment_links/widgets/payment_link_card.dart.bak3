import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';
import '../models/index.dart';

class PaymentLinkCard extends StatelessWidget {
  const PaymentLinkCard({
    super.key,
    required this.link,
    required this.onTap,
  });

  final PaymentLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isFrench = locale.languageCode == 'fr';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: _getStatusColor(link.status).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        _formatAmount(link.amount, link.currency),
                        variant: AppTextVariant.headlineMedium,
                        color: AppColors.gold500,
                      ),
                      if (link.description != null) ...[
                        SizedBox(height: AppSpacing.xs),
                        AppText(
                          link.description!,
                          variant: AppTextVariant.bodyMedium,
                          color: AppColors.textSecondary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusBadge(link.status, isFrench),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            _buildInfoRow(
              Icons.link,
              link.shortCode,
              AppColors.gold500,
            ),
            SizedBox(height: AppSpacing.xs),
            _buildInfoRow(
              Icons.visibility_outlined,
              '${link.viewCount} ${isFrench ? "vue(s)" : "view(s)"}',
              AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.xs),
            _buildInfoRow(
              Icons.schedule,
              _formatDate(link.createdAt),
              AppColors.textSecondary,
            ),
            if (link.isPaid) ...[
              SizedBox(height: AppSpacing.xs),
              _buildInfoRow(
                Icons.person_outline,
                link.paidByName ?? link.paidByPhone ?? 'Unknown',
                AppColors.successBase,
              ),
            ],
            if (_isExpiringSoon(link) && link.isActive) ...[
              SizedBox(height: AppSpacing.sm),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningBase.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.warningBase,
                    ),
                    SizedBox(width: AppSpacing.xs),
                    AppText(
                      isFrench ? 'Expire bientôt' : 'Expiring soon',
                      variant: AppTextVariant.bodySmall,
                      color: AppColors.warningBase,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(PaymentLinkStatus status, bool isFrench) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: AppText(
        status.displayName(isFrench),
        variant: AppTextVariant.bodySmall,
        color: _getStatusColor(status),
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: AppSpacing.xs),
        AppText(
          text,
          variant: AppTextVariant.bodySmall,
          color: color,
        ),
      ],
    );
  }

  Color _getStatusColor(PaymentLinkStatus status) {
    switch (status) {
      case PaymentLinkStatus.pending:
        return AppColors.gold500;
      case PaymentLinkStatus.viewed:
        return AppColors.infoBase;
      case PaymentLinkStatus.paid:
        return AppColors.successBase;
      case PaymentLinkStatus.expired:
        return AppColors.textSecondary;
      case PaymentLinkStatus.cancelled:
        return AppColors.errorBase;
    }
  }

  String _formatAmount(double amount, String currency) {
    final formatter = NumberFormat.currency(
      symbol: currency == 'XOF' ? 'CFA ' : '\$',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    }

    return DateFormat('MMM d').format(date);
  }

  bool _isExpiringSoon(PaymentLink link) {
    final now = DateTime.now();
    final timeUntilExpiry = link.expiresAt.difference(now);
    return timeUntilExpiry.inHours < 6 && timeUntilExpiry.inHours > 0;
  }
}
