import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../design/tokens/index.dart';
import '../../../design/components/primitives/index.dart';

/// Cards Screen - Coming Soon Placeholder
///
/// Future features:
/// - Virtual debit cards for online shopping
/// - Physical card management
/// - Card limits and controls
/// - Transaction notifications
class CardsScreen extends ConsumerWidget {
  const CardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.navigation_cards,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Card illustration
                Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.goldGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    boxShadow: AppShadows.goldGlow,
                  ),
                  child: Stack(
                    children: [
                      // Card chip
                      Positioned(
                        left: AppSpacing.lg,
                        top: AppSpacing.lg,
                        child: Container(
                          width: 40,
                          height: 30,
                          decoration: BoxDecoration(
                            color: AppColors.gold700,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                      ),
                      // Card number placeholder
                      Positioned(
                        left: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              '•••• •••• •••• ••••',
                              variant: AppTextVariant.bodyMedium,
                              color: AppColors.textInverse,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            AppText(
                              'JoonaPay Card',
                              variant: AppTextVariant.labelSmall,
                              color: AppColors.textInverse,
                            ),
                          ],
                        ),
                      ),
                      // Logo
                      Positioned(
                        right: AppSpacing.lg,
                        bottom: AppSpacing.lg,
                        child: Icon(
                          Icons.credit_card,
                          color: AppColors.textInverse.withValues(alpha: 0.5),
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Coming Soon Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: colors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.schedule,
                        color: colors.gold,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppText(
                        l10n.cards_comingSoon,
                        variant: AppTextVariant.labelMedium,
                        color: colors.gold,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Title
                AppText(
                  l10n.cards_title,
                  variant: AppTextVariant.headlineMedium,
                  color: colors.textPrimary,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppSpacing.md),

                // Description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: AppText(
                    l10n.cards_description,
                    variant: AppTextVariant.bodyLarge,
                    color: colors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Features list
                _buildFeatureItem(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  title: l10n.cards_feature1Title,
                  description: l10n.cards_feature1Description,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildFeatureItem(
                  context,
                  icon: Icons.security_outlined,
                  title: l10n.cards_feature2Title,
                  description: l10n.cards_feature2Description,
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildFeatureItem(
                  context,
                  icon: Icons.tune_outlined,
                  title: l10n.cards_feature3Title,
                  description: l10n.cards_feature3Description,
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // Notify button
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: l10n.cards_notifyMe,
                    onPressed: () => _showNotificationDialog(context, l10n, colors),
                    variant: AppButtonVariant.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colors.elevated,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            color: colors.gold,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                title,
                variant: AppTextVariant.labelLarge,
                color: colors.textPrimary,
              ),
              const SizedBox(height: AppSpacing.xxs),
              AppText(
                description,
                variant: AppTextVariant.bodySmall,
                color: colors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showNotificationDialog(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.container,
        title: AppText(
          l10n.cards_notifyDialogTitle,
          variant: AppTextVariant.titleMedium,
          color: colors.textPrimary,
        ),
        content: AppText(
          l10n.cards_notifyDialogMessage,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: AppText(
              l10n.action_cancel,
              variant: AppTextVariant.labelLarge,
              color: colors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.cards_notifySuccess),
                  backgroundColor: colors.success,
                ),
              );
            },
            child: AppText(
              l10n.action_confirm,
              variant: AppTextVariant.labelLarge,
              color: colors.gold,
            ),
          ),
        ],
      ),
    );
  }
}
