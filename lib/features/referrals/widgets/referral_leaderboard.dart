import 'package:usdc_wallet/design/components/primitives/section_header.dart';
import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';

/// Run 382: Referral leaderboard showing top referrers
class ReferralLeaderboard extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const ReferralLeaderboard({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const EmptyState(
        title: 'Aucun classement disponible',
        icon: Icons.leaderboard_outlined,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Classement'),
        const SizedBox(height: AppSpacing.md),
        ...entries.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _LeaderboardTile(
            rank: index + 1,
            entry: item,
          );
        }),
      ],
    );
  }
}

class LeaderboardEntry {
  final String name;
  final int referralCount;
  final String? avatarUrl;

  const LeaderboardEntry({
    required this.name,
    required this.referralCount,
    this.avatarUrl,
  });
}

class _LeaderboardTile extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _LeaderboardTile({required this.rank, required this.entry});

  Color get _rankColor {
    switch (rank) {
      case 1: return AppColors.gold500;
      case 2: return const Color(0xFFC0C0C0);
      case 3: return const Color(0xFFCD7F32);
      default: return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        label: 'Rang $rank: ${entry.name}, ${entry.referralCount} parrainages',
        child: AppCard(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: _rankColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: rank <= 3
                        ? Icon(Icons.emoji_events, color: _rankColor, size: 16)
                        : AppText(
                            '$rank',
                            style: AppTextStyle.labelSmall,
                            color: _rankColor,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                UserAvatar(firstName: entry.name, size: 36),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppText(entry.name, style: AppTextStyle.labelMedium),
                ),
                PillBadge(label: '${entry.referralCount}', backgroundColor: _rankColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
