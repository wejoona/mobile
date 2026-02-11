import 'package:flutter/material.dart';
import '../../../utils/clipboard_utils.dart';
import '../../../utils/share_utils.dart';
import '../providers/referrals_provider.dart';

/// Referral program overview card.
class ReferralCard extends StatelessWidget {
  final ReferralInfo info;

  const ReferralCard({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Invite Friends', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Earn rewards for every friend who joins', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  Expanded(child: Text(info.referralCode, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2))),
                  IconButton(
                    onPressed: () => ClipboardUtils.copy(context, info.referralCode, label: 'Referral code copied'),
                    icon: const Icon(Icons.copy_rounded, color: Colors.white, size: 20),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _StatItem(label: 'Invited', value: '${info.totalReferrals}'),
                const SizedBox(width: 24),
                _StatItem(label: 'Joined', value: '${info.successfulReferrals}'),
                const SizedBox(width: 24),
                _StatItem(label: 'Earned', value: '\$${info.totalEarned.toStringAsFixed(2)}'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => ShareUtils.shareApp(referralCode: info.referralCode),
                icon: const Icon(Icons.share_rounded, size: 18),
                label: const Text('Share Invite Link'),
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11)),
      ],
    );
  }
}
