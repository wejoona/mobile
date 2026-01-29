import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';

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
                color: AppColors.slate,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.insights_outlined,
                size: 60,
                color: AppColors.gold500.withValues(alpha: 0.5),
              ),
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Title
            Text(
              l10n.insights_empty_title,
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.md),

            // Description
            Text(
              l10n.insights_empty_description,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
