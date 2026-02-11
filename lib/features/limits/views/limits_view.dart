import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/features/limits/providers/limits_provider.dart';
import 'package:usdc_wallet/features/limits/widgets/limit_usage_card.dart';
import 'package:usdc_wallet/features/kyc/providers/kyc_provider.dart';
import 'package:usdc_wallet/features/kyc/widgets/kyc_status_card.dart';

/// Transaction limits overview screen.
class LimitsView extends ConsumerWidget {
  const LimitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final limitsAsync = ref.watch(transactionLimitsProvider);
    final kycAsync = ref.watch(kycProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Limits')),
      body: limitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (limits) => ListView(
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
                'Upgrade your KYC level to increase transaction limits. Limits reset daily, weekly, and monthly.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
