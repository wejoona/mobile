import 'package:flutter/material.dart';
import 'package:usdc_wallet/utils/color_utils.dart';

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
          child: Text('Recent', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
              final color = ColorUtils.pastelFromString(r.name);
              final initials = r.name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();

              return GestureDetector(
                onTap: () => onSelect(r),
                child: SizedBox(
                  width: 64,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: color,
                        backgroundImage: r.avatarUrl != null ? NetworkImage(r.avatarUrl!) : null,
                        child: r.avatarUrl == null ? Text(initials, style: TextStyle(color: ColorUtils.contrastingText(color), fontWeight: FontWeight.w600, fontSize: 14)) : null,
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
