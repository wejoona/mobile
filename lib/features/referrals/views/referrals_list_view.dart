import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usdc_wallet/design/components/primitives/user_avatar.dart';
import 'package:usdc_wallet/features/referrals/providers/referrals_provider.dart';
import 'package:usdc_wallet/features/referrals/widgets/referral_card.dart';
import 'package:usdc_wallet/utils/duration_extensions.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';
import 'package:usdc_wallet/utils/currency_utils.dart';
import 'package:usdc_wallet/utils/user_facing_errors.dart';

/// Referrals program screen.
class ReferralsListView extends ConsumerWidget {
  const ReferralsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(referralProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.referrals_title)),
      body: referralAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(AppLocalizations.of(context)!.referrals_error(UserFacingErrors.message(e)))),
        data: (info) => RefreshIndicator(
          onRefresh: () => ref.refresh(referralProvider.future),
          child: ListView(
            children: [
              ReferralCard(referralCode: info.referralCode, referralCount: info.referrals.length),
              const SizedBox(height: 16),
              if (info.referrals.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(AppLocalizations.of(context)!.referrals_yourReferrals, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                ...info.referrals.map((entry) => ListTile(
                  leading: UserAvatar(
                    firstName: entry.referredName.split(' ').first,
                    lastName: entry.referredName.split(' ').length > 1 ? entry.referredName.split(' ').last : null,
                    size: 40,
                  ),
                  title: Text(entry.referredName),
                  subtitle: Text(entry.createdAt.timeAgo),
                  trailing: entry.reward != null
                      ? Text('+${formatXof(entry.reward!)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600))
                      : Text(entry.status, style: theme.textTheme.bodySmall),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
