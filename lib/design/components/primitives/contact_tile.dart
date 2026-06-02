import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/components/primitives/app_text.dart';
import 'package:usdc_wallet/design/components/primitives/user_avatar.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/features/contacts/widgets/korido_account_badge.dart';

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
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            Stack(
              clipBehavior: Clip.none,
              children: [
                UserAvatar(
                  imageUrl: contact.avatarUrl,
                  firstName: contact.name.split(' ').first,
                  lastName: contact.name.split(' ').length > 1
                      ? contact.name.split(' ').last
                      : null,
                  size: 44,
                  showBorder: contact.isKoridoUser,
                  borderColor: colors.gold,
                ),
                if (contact.isKoridoUser)
                  const Positioned(
                    right: -2,
                    bottom: -2,
                    child: KoridoAccountBadge(compact: true),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Name and phone
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          contact.name,
                          variant: AppTextVariant.bodyMedium,
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (contact.isKoridoUser) ...[
                        const SizedBox(width: 4),
                        const KoridoAccountBadge(compact: true),
                      ],
                    ],
                  ),
                  if (showPhone && contact.phone != null) ...[
                    const SizedBox(height: 2),
                    AppText(
                      contact.phone!,
                      variant: AppTextVariant.bodySmall,
                      color: colors.textSecondary,
                    ),
                  ],
                ],
              ),
            ),
            // Trailing
            if (trailing != null) trailing!,
            if (trailing == null && contact.isFavorite)
              Icon(Icons.star_rounded, color: colors.gold, size: 18),
          ],
        ),
      ),
    );
  }
}
