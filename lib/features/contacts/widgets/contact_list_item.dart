import 'package:flutter/material.dart';
import 'package:usdc_wallet/design/tokens/index.dart';
import 'package:usdc_wallet/design/components/primitives/index.dart';
import 'package:usdc_wallet/domain/entities/contact.dart';
import 'package:usdc_wallet/design/tokens/theme_colors.dart';

/// Run 361: Contact list item widget with Korido user indicator
class ContactListItem extends StatelessWidget {
  final Contact contact;
  final VoidCallback? onTap;
  final bool showKoridoStatus;
  final Widget? trailing;

  const ContactListItem({
    super.key,
    required this.contact,
    this.onTap,
    this.showKoridoStatus = true,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${contact.displayName}'
          '${contact.isKoridoUser ? ", utilisateur Korido" : ""}',
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Stack(
                  children: [
                    UserAvatar(
                      firstName: contact.displayName,
                      imageUrl: contact.avatarUrl,
                      size: 44,
                    ),
                    if (showKoridoStatus && contact.isKoridoUser)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: context.colors.gold,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: context.colors.canvas,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10,
                            color: context.colors.canvas,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        contact.displayName,
                        style: AppTextStyle.labelMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      AppText(
                        contact.phoneNumber ?? '',
                        style: AppTextStyle.bodySmall,
                        color: context.colors.textTertiary,
                      ),
                    ],
                  ),
                ),
                if (trailing != null) trailing!,
                if (contact.isKoridoUser && trailing == null)
                  PillBadge(
                    label: 'Korido',
                    backgroundColor: context.colors.gold,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
