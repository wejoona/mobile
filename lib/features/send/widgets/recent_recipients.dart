import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/user_avatar.dart';
import 'package:usdc_wallet/l10n/app_localizations.dart';

/// Horizontal list of recent recipients for quick send.
class RecentRecipients extends StatelessWidget {
  final List<RecentRecipientData> recipients;
  final ValueChanged<RecentRecipientData> onSelect;

  const RecentRecipients({super.key, required this.recipients, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (recipients.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(AppLocalizations.of(context)!.common_recent, style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: recipients.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (_, index) {
              final r = recipients[index];

              return GestureDetector(
                onTap: () => onSelect(r),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      UserAvatar(
                        imageUrl: r.avatarUrl,
                        firstName: r.name.split(' ').first,
                        lastName: r.name.split(' ').length > 1 ? r.name.split(' ').last : null,
                        size: UserAvatar.sizeMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(r.name.split(' ').first, style: theme.textTheme.labelSmall, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecentRecipientData {
  final String id;
  final String name;
  final String phone;
  final String? avatarUrl;

  const RecentRecipientData({required this.id, required this.name, required this.phone, this.avatarUrl});
}
