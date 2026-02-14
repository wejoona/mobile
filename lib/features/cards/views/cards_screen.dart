import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Cards Screen - Coming Soon
///
/// Displays a "Coming Soon" state for virtual card functionality.
/// Future features:
/// - Virtual debit cards
/// - Card limits and controls
/// - Freeze/unfreeze
/// - Copy card number
/// - Transaction history per card
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xxl),

              // Virtual card mockup
              _buildCardMockup(colors),

              const SizedBox(height: AppSpacing.xxxl),

              // Coming Soon badge
              _buildComingSoonBadge(l10n, colors),

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

              // Features
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

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.cards_notifyMe,
                  onPressed: () => _showNotifyDialog(context, l10n, colors),
                  variant: AppButtonVariant.secondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardMockup(ThemeColors colors) {
    return Container(
      width: 300,
      height: 180,
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
          // EMV chip
          Positioned(
            left: AppSpacing.lg,
            top: AppSpacing.xxl,
            child: Container(
              width: 48,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.gold500,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),

          // Card number
          Positioned(
            left: AppSpacing.lg,
            bottom: AppSpacing.huge,
            child: AppText(
              '•••• •••• •••• ••••',
              variant: AppTextVariant.bodyLarge,
              color: AppColors.textInverse,
            ),
          ),

          // Cardholder name
          Positioned(
            left: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  'CARDHOLDER NAME',
                  variant: AppTextVariant.labelSmall,
                  color: AppColors.textInverse.withValues(alpha: 0.7),
                ),
                const SizedBox(height: AppSpacing.xxs),
                AppText(
                  'Korido Card',
                  variant: AppTextVariant.bodyMedium,
                  color: AppColors.textInverse,
                ),
              ],
            ),
          ),

          // Card brand
          Positioned(
            right: AppSpacing.lg,
            bottom: AppSpacing.lg,
            child: Icon(
              Icons.credit_card,
              color: AppColors.textInverse.withValues(alpha: 0.4),
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonBadge(AppLocalizations l10n, ThemeColors colors) {
    return Container(
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

  void _showNotifyDialog(
    BuildContext context,
    AppLocalizations l10n,
    ThemeColors colors,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.container,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xxl),
        ),
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
