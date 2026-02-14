import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/colors.dart';
import 'package:usdc_wallet/design/tokens/spacing.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

class EmptyInsightsState extends StatelessWidget {
  const EmptyInsightsState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: context.colors.container,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_outlined,
                size: 60,
                color: context.colors.gold.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Title
            AppText(
              l10n.insights_empty_title,
              variant: AppTextVariant.headlineSmall,
              color: context.colors.textPrimary,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Description
            AppText(
              l10n.insights_empty_description,
              variant: AppTextVariant.bodyMedium,
              color: context.colors.textSecondary,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
