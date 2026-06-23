import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_usage_card.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_status_card.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/state/fsm/fsm_provider.dart';

/// Transaction limits overview screen.
class LimitsView extends ConsumerWidget {
  const LimitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(transactionLimitsProvider);
    final kycAsync = ref.watch(kycProfileProvider);
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: AppText(
          l10n.limits_title,
          variant: AppTextVariant.titleLarge,
          color: colors.textPrimary,
        ),
      ),
      body: RefreshIndicator(
        color: colors.gold,
        backgroundColor: colors.container,
        onRefresh: () async {
          ref.invalidate(transactionLimitsProvider);
          ref.invalidate(kycProfileProvider);
        },
        child: limitsAsync.when(
          loading: () =>
              Center(child: CircularProgressIndicator(color: colors.gold)),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              AppCard(
                variant: AppCardVariant.flat,
                child: AppText(
                  l10n.limits_error(e.toString()),
                  variant: AppTextVariant.bodyMedium,
                  color: colors.errorText,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          data: (limits) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            children: [
              LimitUsageCard(limits: limits),
              const SizedBox(height: AppSpacing.md),
              kycAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (kyc) => KycStatusCard(
                  profile: kyc,
                  onUpgrade: () => context.fsmPush('/kyc'),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                variant: AppCardVariant.flat,
                borderRadius: AppRadius.lg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: colors.gold, size: 20),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppText(
                            l10n.limits_aboutTitle,
                            variant: AppTextVariant.labelLarge,
                            color: colors.textPrimary,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          AppText(
                            l10n.limits_aboutDescription,
                            variant: AppTextVariant.bodySmall,
                            color: colors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
