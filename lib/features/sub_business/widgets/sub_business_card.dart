import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/features/sub_business/models/sub_business.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';

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
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.container,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: context.colors.gold.withValues(alpha: 0.2),
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
                    color: context.colors.gold.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(
                    _getIconForType(subBusiness.type),
                    color: context.colors.gold,
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
                          color: context.colors.textSecondary,
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
              formatXof(subBusiness.balance),
              variant: AppTextVariant.headlineMedium,
              color: context.colors.gold,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: AppSpacing.xs),

            // Stats row
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  size: 16,
                  color: context.colors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xxs),
                AppText(
                  '${subBusiness.staffCount} staff',
                  variant: AppTextVariant.bodySmall,
                  color: context.colors.textSecondary,
                ),
                SizedBox(width: AppSpacing.md),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.elevated,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: AppText(
                    _getTypeLabel(subBusiness.type),
                    variant: AppTextVariant.bodySmall,
                    color: context.colors.textSecondary,
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
                      label: Text(AppLocalizations.of(context)!.subBusiness_transfer),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.gold,
                        side: BorderSide(color: context.colors.gold.withValues(alpha: 0.3)),
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
                      label: Text(AppLocalizations.of(context)!.subBusiness_view),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.colors.textSecondary,
                        side: BorderSide(
                          color: context.colors.textSecondary.withValues(alpha: 0.3),
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
