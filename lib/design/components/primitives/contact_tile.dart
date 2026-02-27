import 'package:flutter/material.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/design/components/primitives/user_avatar.dart';

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

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            UserAvatar(
              imageUrl: contact.avatarUrl,
              firstName: contact.name.split(' ').first,
              lastName: contact.name.split(' ').length > 1 ? contact.name.split(' ').last : null,
              size: 44,
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

}
