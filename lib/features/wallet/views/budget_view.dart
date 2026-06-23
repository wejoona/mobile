import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/auth/providers/auth_provider.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/services/feature_subscriptions/feature_subscription_service.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';
import 'package:usdc_wallet/utils/context_extensions.dart';

class BudgetView extends ConsumerStatefulWidget {
  const BudgetView({super.key});

  @override
  ConsumerState<BudgetView> createState() => _BudgetViewState();
}

class _BudgetViewState extends ConsumerState<BudgetView> {
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.services_budget,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.textPrimary),
          onPressed: () => context.fsmSafePop(fallbackRoute: '/home'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          children: [
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              variant: AppCardVariant.elevated,
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.gold.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      border: Border.all(
                        color: colors.gold.withValues(alpha: 0.26),
                      ),
                    ),
                    child: Icon(
                      Icons.savings_outlined,
                      color: colors.gold,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  AppText(
                    'Budget controls are being prepared',
                    variant: AppTextVariant.headlineSmall,
                    color: colors.textPrimary,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  AppText(
                    'We will turn real transaction data into monthly limits, alerts, and spending categories once the budget service is live.',
                    variant: AppTextVariant.bodyMedium,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  _CapabilityRow(
                    icon: Icons.pie_chart_outline_rounded,
                    text: 'Category budgets from actual transactions',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CapabilityRow(
                    icon: Icons.notifications_active_outlined,
                    text: 'Alerts before a limit is reached',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CapabilityRow(
                    icon: Icons.public_outlined,
                    text: 'Region-aware spending rails for Abidjan and the US',
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                  AppButton(
                    label: _isSubmitting
                        ? 'Subscribing...'
                        : 'Keep me informed',
                    onPressed: _isSubmitting ? null : () => _subscribe(l10n),
                    variant: AppButtonVariant.primary,
                    isFullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _subscribe(AppLocalizations l10n) async {
    setState(() => _isSubmitting = true);
    final authState = ref.read(authProvider);
    final user = authState.user;

    try {
      await ref
          .read(featureSubscriptionServiceProvider)
          .subscribe(
            FeatureSubscriptionRequest(
              featureKey: 'budget_controls',
              source: 'budget_view',
              phone: user?.phone ?? authState.phone,
              email: user?.email,
              featureName: 'Budget controls',
              requestedFeature: 'budget_controls_launch',
              countryCode: user?.countryCode,
              locale: user?.preferredLocale,
              metadata: {'surface': 'wallet_budget'},
            ),
          );

      if (!mounted) return;
      context.showSnack(l10n.budget_notifySuccess, tone: AppSnackTone.success);
    } catch (e) {
      if (!mounted) return;
      context.showSnack(
        l10n.common_errorFormat(e.toString()),
        tone: AppSnackTone.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

class _CapabilityRow extends StatelessWidget {
  const _CapabilityRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: colors.gold, size: 20),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: AppText(
            text,
            variant: AppTextVariant.bodyMedium,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
