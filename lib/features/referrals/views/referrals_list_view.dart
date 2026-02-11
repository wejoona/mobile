import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/referrals_provider.dart';
import '../widgets/referral_card.dart';
import '../../../utils/duration_extensions.dart';

/// Referrals program screen.
class ReferralsListView extends ConsumerWidget {
  const ReferralsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final referralAsync = ref.watch(referralProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Referrals')),
      body: referralAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (info) => RefreshIndicator(
          onRefresh: () => ref.refresh(referralProvider.future),
          child: ListView(
            children: [
              ReferralCard(info: info),
              const SizedBox(height: 16),
              if (info.referrals.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Your Referrals', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 8),
                ...info.referrals.map((entry) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: entry.status == 'completed' ? Colors.green.shade100 : Colors.orange.shade100,
                    child: Icon(
                      entry.status == 'completed' ? Icons.check_rounded : Icons.hourglass_top_rounded,
                      color: entry.status == 'completed' ? Colors.green.shade700 : Colors.orange.shade700,
                      size: 20,
                    ),
                  ),
                  title: Text(entry.referredName),
                  subtitle: Text(entry.createdAt.timeAgo),
                  trailing: entry.reward != null
                      ? Text('+\$${entry.reward!.toStringAsFixed(2)}', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w600))
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
