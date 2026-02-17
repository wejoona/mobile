import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_usage_card.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_status_card.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Transaction limits overview screen.
class LimitsView extends ConsumerWidget {
  const LimitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(transactionLimitsProvider);
    final kycAsync = ref.watch(kycProfileProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.limits_title)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(transactionLimitsProvider);
          ref.invalidate(kycProfileProvider);
        },
        child: limitsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [Center(child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(AppLocalizations.of(context)!.limits_error(e.toString())),
            ))],
          ),
          data: (limits) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              LimitUsageCard(limits: limits),
              const SizedBox(height: 8),
              kycAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (kyc) => KycStatusCard(profile: kyc, onUpgrade: () {}),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Augmentez votre niveau KYC pour accroître vos limites de transaction. Les limites se réinitialisent quotidiennement, hebdomadairement et mensuellement.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
