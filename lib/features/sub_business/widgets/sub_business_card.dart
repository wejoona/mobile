import 'package:flutter/material.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/app_text.dart';
import '../models/sub_business.dart';
import 'package:intl/intl.dart';

/// Card widget displaying a sub-business
class SubBusinessCard extends StatelessWidget {
  const SubBusinessCard({
    super.key,
    required this.subBusiness,
    required this.onTap,
    this.onTransfer,
  });

  final SubBusiness subBusiness;
  final VoidCallback onTap;
  final VoidCallback? onTransfer;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.slate,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: AppColors.gold500.withOpacity(0.2),
            width: 1,
          ),
        ),
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold500.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _getIconForType(subBusiness.type),
                    color: AppColors.gold500,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        subBusiness.name,
                        variant: AppTextVariant.bodyLarge,
                        fontWeight: FontWeight.w600,
                      ),
                      if (subBusiness.description != null) ...[
                        SizedBox(height: AppSpacing.xxs),
                        AppText(
                          subBusiness.description!,
                          variant: AppTextVariant.bodySmall,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Balance
            AppText(
              currencyFormat.format(subBusiness.balance),
              variant: AppTextVariant.headlineMedium,
              color: AppColors.gold500,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: AppSpacing.xs),

            // Stats row
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xxs),
                AppText(
                  '${subBusiness.staffCount} staff',
                  variant: AppTextVariant.bodySmall,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.md),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.charcoal,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: AppText(
                    _getTypeLabel(subBusiness.type),
                    variant: AppTextVariant.bodySmall,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            // Quick actions
            if (onTransfer != null) ...[
              SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTransfer,
                      icon: const Icon(Icons.swap_horiz, size: 16),
                      label: const Text('Transfer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.gold500,
                        side: BorderSide(color: AppColors.gold500.withOpacity(0.3)),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.visibility_outlined, size: 16),
                      label: const Text('View'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: BorderSide(
                          color: AppColors.textSecondary.withOpacity(0.3),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(SubBusinessType type) {
    switch (type) {
      case SubBusinessType.department:
        return Icons.business_center;
      case SubBusinessType.branch:
        return Icons.store;
      case SubBusinessType.subsidiary:
        return Icons.corporate_fare;
      case SubBusinessType.team:
        return Icons.groups;
    }
  }

  String _getTypeLabel(SubBusinessType type) {
    switch (type) {
      case SubBusinessType.department:
        return 'Department';
      case SubBusinessType.branch:
        return 'Branch';
      case SubBusinessType.subsidiary:
        return 'Subsidiary';
      case SubBusinessType.team:
        return 'Team';
    }
  }
}
