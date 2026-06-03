import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/core/l10n/app_strings.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';

class VirtualCardView extends ConsumerWidget {
  const VirtualCardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const AppText(
          AppStrings.virtualCardTitle,
          variant: AppTextVariant.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Card illustration
              Container(
                width: 320,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colors.gold.withValues(alpha: 0.15),
                      colors.gold.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                  border: Border.all(
                    color: colors.gold.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Stack(
                  children: [
                    // Chip placeholder
                    Positioned(
                      left: 24,
                      top: 40,
                      child: Container(
                        width: 45,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.gold.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    // Card number placeholder
                    Positioned(
                      left: 24,
                      bottom: 60,
                      child: Row(
                        children: List.generate(
                          4,
                          (i) => Padding(
                            padding: const EdgeInsets.only(right: 16),
                            child: AppText(
                              '••••',
                              variant: AppTextVariant.titleMedium,
                              color: colors.textTertiary.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Logo placeholder
                    Positioned(
                      right: 24,
                      top: 20,
                      child: Icon(
                        Icons.credit_card,
                        color: colors.gold.withValues(alpha: 0.4),
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Coming Soon badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: AppText(
                  'COMING SOON',
                  variant: AppTextVariant.labelLarge,
                  color: colors.gold,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              AppText(
                AppStrings.virtualDebitCard,
                variant: AppTextVariant.headlineSmall,
                color: colors.textPrimary,
              ),

              const SizedBox(height: AppSpacing.md),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: AppText(
                  'Spend your balance anywhere Visa is accepted. '
                  'Shop online, pay subscriptions, and manage your spending — all from your phone.',
                  variant: AppTextVariant.bodyMedium,
                  color: colors.textSecondary,
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Feature highlights
              _FeatureRow(
                icon: Icons.lock_outline,
                text: 'Freeze & unfreeze instantly',
                colors: colors,
              ),
              const SizedBox(height: AppSpacing.md),
              _FeatureRow(
                icon: Icons.speed,
                text: 'Custom spending limits',
                colors: colors,
              ),
              const SizedBox(height: AppSpacing.md),
              _FeatureRow(
                icon: Icons.notifications_outlined,
                text: 'Real-time transaction alerts',
                colors: colors,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              AppButton(
                label: l10n.cards_notifyMe,
                onPressed: () => _subscribe(context, ref, l10n, colors),
                variant: AppButtonVariant.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
    ThemeColors colors,
  ) async {
    final authState = ref.read(authProvider);
    final user = authState.user;

    try {
      await ref
          .read(featureSubscriptionServiceProvider)
          .subscribe(
            FeatureSubscriptionRequest(
              featureKey: 'virtual_card',
              source: 'wallet_virtual_card_view',
              phone: user?.phone ?? authState.phone,
              email: user?.email,
              metadata: {
                'surface': 'wallet_virtual_card',
                'featureName': 'Korido virtual card',
                if (user?.countryCode != null) 'countryCode': user!.countryCode,
                if (user?.preferredLocale != null)
                  'locale': user!.preferredLocale,
              },
            ),
          );

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.cards_notifySuccess),
          backgroundColor: colors.success,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.common_errorFormat(e.toString())),
          backgroundColor: colors.error,
        ),
      );
    }
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final ThemeColors colors;

  const _FeatureRow({
    required this.icon,
    required this.text,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: colors.gold),
        const SizedBox(width: AppSpacing.sm),
        AppText(
          text,
          variant: AppTextVariant.bodyMedium,
          color: colors.textSecondary,
        ),
      ],
    );
  }
}
