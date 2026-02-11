import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/utils/color_utils.dart';

/// Standard contact list tile with avatar.
class ContactTile extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool showPhone;

  const ContactTile({
    super.key,
    required this.contact,
    this.onTap,
    this.trailing,
    this.showPhone = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final avatarColor = ColorUtils.pastelFromString(contact.name);
    final initials = _getInitials(contact.name);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: avatarColor,
              backgroundImage: contact.avatarUrl != null
                  ? NetworkImage(contact.avatarUrl!)
                  : null,
              child: contact.avatarUrl == null
                  ? Text(
                      initials,
                      style: TextStyle(
                        color: ColorUtils.contrastingText(avatarColor),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Name and phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    contact.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showPhone && contact.phone != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.phone!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // Trailing
            if (trailing != null) trailing!,
            if (trailing == null && contact.isFavorite)
              Icon(
                Icons.star_rounded,
                color: Colors.amber.shade600,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.isEmpty) return '';
    if (words.length == 1) {
      return words[0].substring(0, words[0].length.clamp(0, 2)).toUpperCase();
    }
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }
}
